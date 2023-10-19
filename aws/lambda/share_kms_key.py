import json
import logging
import os
import re
import traceback
from typing import Any, Dict, List, Optional, Set

import boto3
from botocore.exceptions import ClientError

logger = logging.getLogger("orca")
logger.setLevel(logging.INFO)

KMS_SID_PREFIX = "OrcaKMS"


def tags_dict(
    from_object: Dict[str, Any], key: str = "Key", value: str = "Value", tags: str = "Tags"
) -> Dict[str, str]:
    return {t[key]: t[value] for t in from_object.get(tags, {})}


def validate_snapshot(
    ec2: boto3.session.Session.client,  # type: ignore
    *,
    snapshot_id: str,
    image_id: Optional[str],
    snapshots_res: Optional[Dict[str, Any]] = None,
) -> None:
    if image_id:
        assert_snapshot_belongs_to_image(ec2, image_id, snapshot_id)
    else:
        assert_snapshot_created_by_orca(ec2, snapshot_id, snapshots_res)


def assert_snapshot_created_by_orca(
    ec2: boto3.session.Session.client, snapshot_id: str, snapshots_res: Optional[Dict[str, Any]] = None  # type: ignore
) -> None:
    # verify the snapshot has Orca tag
    if not snapshots_res:
        snapshots_res = ec2.describe_snapshots(SnapshotIds=[snapshot_id])  # type: ignore
    assert snapshots_res
    if not len(snapshots_res["Snapshots"]):
        raise Exception(f"no such snapshot {snapshot_id}")
    tags = tags_dict(snapshots_res["Snapshots"][0])
    if "Orca" not in tags:
        raise Exception(f"{snapshot_id} is not Orca snapshot")


def assert_snapshot_belongs_to_image(ec2: boto3.session.Session.client, image_id: str, snapshot_id: str) -> None:  # type: ignore
    images_res = ec2.describe_images(ImageIds=[image_id])  # type: ignore
    if not images_res["Images"]:
        raise Exception(f"no such image {image_id}")
    logger.debug(f"making sure that the snapshot {snapshot_id} belongs to the image {image_id}")
    image_info = images_res["Images"][0]
    image_snapshots: Set[str] = set()
    for block_device in image_info["BlockDeviceMappings"]:
        snap_id = block_device.get("Ebs", {}).get("SnapshotId")
        if snap_id:
            image_snapshots.add(snap_id)
    if snapshot_id not in image_snapshots:
        raise Exception(f"snapshot {snapshot_id} not belongs to the image {image_id}")


def build_orca_kms_policy(account_id: str, partition: str) -> List[Dict[str, Any]]:
    """Build a policy that will be used by the Service Account to start a VM with the encrypted snapshot/s"""

    def sid(idx: int) -> str:
        return f"{KMS_SID_PREFIX}{idx}{account_id}"

    return [
        {
            "Sid": sid(1),
            "Effect": "Allow",
            "Principal": {"AWS": f"arn:{partition}:iam::{account_id}:root"},
            "Action": ["kms:Encrypt", "kms:Decrypt", "kms:ReEncrypt*", "kms:GenerateDataKey*", "kms:DescribeKey"],
            "Resource": "*",
        },
        {
            "Sid": sid(2),
            "Effect": "Allow",
            "Principal": {"AWS": f"arn:{partition}:iam::{account_id}:root"},
            "Action": [
                "kms:CreateGrant",
                "kms:ListGrants",
                "kms:RevokeGrant",
            ],
            "Resource": "*",
        },
        {
            "Sid": sid(3),
            "Effect": "Allow",
            "Principal": {
                "AWS": f"arn:{partition}:iam::{account_id}:role/aws-service-role/spot.amazonaws.com/AWSServiceRoleForEC2Spot"
            },
            "Action": ["kms:Encrypt", "kms:Decrypt", "kms:ReEncrypt*", "kms:GenerateDataKey*", "kms:DescribeKey"],
            "Resource": "*",
        },
        {
            "Sid": sid(4),
            "Effect": "Allow",
            "Principal": {
                "AWS": f"arn:{partition}:iam::{account_id}:role/aws-service-role/spot.amazonaws.com/AWSServiceRoleForEC2Spot"
            },
            "Action": ["kms:CreateGrant", "kms:ListGrants", "kms:RevokeGrant"],
            "Resource": "*",
            "Condition": {"Bool": {"kms:GrantIsForAWSResource": "true"}},
        },
    ]


def share_kms_key(
    role_arn: Optional[str],
    external_id: Optional[str],
    kms_key_id: str,
    snapshot_id: str,
    image_id: Optional[str],
    region: str,
    is_inaccount: bool,
    policy_type: Optional[str],
) -> Dict[str, Any]:
    sts = boto3.client("sts")
    caller_identity = sts.get_caller_identity()
    account_id = caller_identity["Account"]
    partition = caller_identity["Arn"].split(":")[1]
    client_extras = {}
    if role_arn and external_id and policy_type != "target_lambda":
        # get the kms client of the target account
        creds = sts.assume_role(
            RoleArn=role_arn,
            ExternalId=external_id,
            RoleSessionName="orca-security-secure-kms-key-share",
        )["Credentials"]
        client_extras = dict(
            aws_access_key_id=creds["AccessKeyId"],
            aws_secret_access_key=creds["SecretAccessKey"],
            aws_session_token=creds["SessionToken"],
        )
    kms = boto3.client("kms", region_name=region, **client_extras)

    # get the kms key id
    ec2 = boto3.client("ec2", region_name=region, **client_extras)
    if (is_inaccount and (not kms_key_id)) or (not is_inaccount):
        snapshots_res = ec2.describe_snapshots(SnapshotIds=[snapshot_id])
        kms_key_id = snapshots_res["Snapshots"][0]["KmsKeyId"]
        if not is_inaccount:
            validate_snapshot(ec2, snapshot_id=snapshot_id, image_id=image_id, snapshots_res=snapshots_res)

    # check whether this key is created with the aws account's default kms key
    response = kms.describe_key(KeyId=kms_key_id)
    metadata = response["KeyMetadata"]
    key_manager = metadata["KeyManager"]
    if key_manager == "AWS":
        logger.info(f"{kms_key_id} is account default key")
        raise Exception(f"{kms_key_id} is account default key")
    elif key_manager != "CUSTOMER":
        raise Exception(f"{kms_key_id} encrypted with unknown key manager: {key_manager}")

    # see whether they key was already shared
    response = kms.get_key_policy(KeyId=kms_key_id, PolicyName="default")
    policy = json.loads(response["Policy"])
    policy_sids = {rule["Sid"] for rule in policy["Statement"] if "Sid" in rule}
    account_policy: List[Dict[str, Any]] = []
    accounts: List[str] = []
    if policy_type == "target_lambda":
        scanner_account_id = os.environ["SCANNER_ACCOUNT_ID"]
        accounts = [scanner_account_id]
        account_policy += build_orca_kms_policy(scanner_account_id, partition)
    elif is_inaccount:
        accounts = [account_id]
        account_policy += build_orca_kms_policy(account_id, partition)
    else:
        accounts = os.environ["ORCA_SCANNER_ACCOUNTS"].split(",")
        for _account_id in accounts:
            account_policy += build_orca_kms_policy(_account_id, partition)

    required_sids = {i["Sid"] for i in account_policy}
    found = len(required_sids - policy_sids) == 0
    if found:
        return {"result": "ok"}

    # extend the key policy to include permissions for the Service Account.
    def in_policy(sid: str) -> bool:
        kms_sid_re = re.compile(
            rf"{re.escape(KMS_SID_PREFIX)}\d{{1,3}}({'|'.join(re.escape(account) for account in accounts)})"
        )
        return bool(kms_sid_re.match(sid))

    policy["Statement"] = [
        rule for rule in policy["Statement"] if (not in_policy(rule.get("Sid", "")))
    ] + account_policy

    kms.put_key_policy(KeyId=kms_key_id, PolicyName="default", Policy=json.dumps(policy))
    return {"result": "ok"}


def handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    try:
        logger.info(f"called with: {event=}")

        # input parameters:
        role_arn = event.get("role_arn")
        external_id = event.get("role_external_id")
        kms_key_id = event["kms_key_id"]
        snapshot_id = event["snapshot_id"]
        image_id = event.get("image_id")
        region = event["region_name"]
        policy_type = event.get("policy_type")
        is_inaccount = os.environ.get("SCAN_MODE", "inaccount").lower() == "inaccount"

        return share_kms_key(
            role_arn, external_id, kms_key_id, snapshot_id, image_id, region, is_inaccount, policy_type
        )

    except ClientError as e:
        code = e.response["Error"]["Code"]
        message = e.response["Error"]["Message"]
        return {
            "result": "exception",
            "exception": json.dumps(str(e)),
            "backtrace": traceback.format_exc(),
            "code": code,
            "message": message,
        }
    except Exception as e:
        return {"result": "exception", "exception": json.dumps(str(e)), "backtrace": traceback.format_exc()}
