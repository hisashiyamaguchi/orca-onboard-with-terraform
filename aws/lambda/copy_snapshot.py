import json
import logging
import traceback
from typing import Any, Dict, List, Optional, Set

import boto3
from botocore.exceptions import ClientError

logger = logging.getLogger("orca")
logger.setLevel(logging.INFO)


def to_key_value_list(d: Dict[str, str]) -> List[Dict[str, str]]:
    return [{"Key": k, "Value": v} for k, v in d.items()]


def tags_dict(object: Dict[str, Any], key: str = "Key", value: str = "Value", tags: str = "Tags") -> Dict[str, str]:
    return {t[key]: t[value] for t in object.get(tags, {})}


def validate_snapshot(ec2: boto3.session.Session.client, *, snapshot_id: str, image_id: Optional[str]) -> None:  # type: ignore
    if image_id:
        images_res = ec2.describe_images(ImageIds=[image_id])  # type: ignore
        if not len(images_res["Images"]):
            raise Exception(f"no such image {image_id}")

        logger.info(f"making sure that the snapshot {snapshot_id} belongs to the image {image_id}")
        image_info = images_res["Images"][0]
        image_snapshots: Set[str] = set()
        for block_device in image_info["BlockDeviceMappings"]:
            snap_id = block_device.get("Ebs", {}).get("SnapshotId")
            if snap_id:
                image_snapshots.add(snap_id)
        if snapshot_id not in image_snapshots:
            raise Exception(f"snapshot {snapshot_id} not belongs to the image {image_id}")
    else:
        snapshots_res = ec2.describe_snapshots(SnapshotIds=[snapshot_id])  # type: ignore
        if not len(snapshots_res["Snapshots"]):
            raise Exception(f"no such snapshot {snapshot_id}")

        tags = tags_dict(snapshots_res["Snapshots"][0])
        if "Orca" not in tags:
            raise Exception(f"{snapshot_id} is not Orca snapshot")


def copy_snapshot(
    role_arn: Optional[str],
    role_external_id: Optional[str],
    snapshot_id: str,
    image_id: Optional[str],
    region: str,
    kms_key_id: str,
    policy_type: Optional[str],
    snapshot_tags: Dict[str, str],
) -> Dict[str, Any]:
    """Initiate a copy of an encrypted snapshot with a new kms key"""

    logger.info(f"copying snapshot {snapshot_id} {image_id=} {role_arn=} {role_external_id=} {region=} {kms_key_id=}")

    sts = boto3.client("sts")
    # get the target account's ec2 client
    client_init_extras = {}
    if role_arn and role_external_id and policy_type != "target_lambda":
        assumed_role = sts.assume_role(
            RoleArn=role_arn,
            ExternalId=role_external_id,
            RoleSessionName="orca-security-secure-copy-snapshot",
        )
        credentials = assumed_role["Credentials"]
        client_init_extras = dict(
            aws_access_key_id=credentials["AccessKeyId"],
            aws_secret_access_key=credentials["SecretAccessKey"],
            aws_session_token=credentials["SessionToken"],
        )

    ec2 = boto3.client(
        "ec2",
        region_name=region,
        **client_init_extras,
    )

    validate_snapshot(ec2, snapshot_id=snapshot_id, image_id=image_id)

    response: Dict[str, Any] = ec2.copy_snapshot(
        Description=f"Orca - Copy of encrypted {snapshot_id}",
        SourceSnapshotId=snapshot_id,
        SourceRegion=region,
        DestinationRegion=region,
        Encrypted=True,
        KmsKeyId=kms_key_id,
        TagSpecifications=[
            {
                "ResourceType": "snapshot",
                "Tags": to_key_value_list(snapshot_tags),
            }
        ],
    )

    logger.info(f'requested copy of snapshot {snapshot_id} to snapshot {response["SnapshotId"]}')
    return response


def handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """Main lambda entrypoint"""
    try:
        sts = boto3.client("sts")
        account_id = sts.get_caller_identity()["Account"]
        logger.info(f"called with: {event=} {account_id=}")

        # input parameters
        role_arn = event.get("role_arn")
        role_external_id = event.get("role_external_id")
        kms_key_id = event["kms_key_id"]
        region_name = event["region_name"]
        snapshot_id = event["snapshot_id"]
        image_id = event.get("image_id")
        policy_type = event.get("policy_type")
        snapshot_tags = event.get("snapshot_tags", {})
        # perform the copy
        response = copy_snapshot(
            role_arn, role_external_id, snapshot_id, image_id, region_name, kms_key_id, policy_type, snapshot_tags
        )
        return {"result": "ok", "response": response}

    except ClientError as e:
        logger.exception("snapshot copy failed")
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
        logger.exception("snapshot copy failed")
        return {"result": "exception", "exception": json.dumps(str(e)), "backtrace": traceback.format_exc()}
