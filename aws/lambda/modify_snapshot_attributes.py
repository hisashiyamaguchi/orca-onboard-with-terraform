import json
import logging
import os
import traceback
from typing import Any, Dict, Optional

import boto3
from botocore.exceptions import ClientError

logger = logging.getLogger("orca")
logger.setLevel(logging.INFO)


def tags_dict(object: Dict[str, Any], key: str = "Key", value: str = "Value", tags: str = "Tags") -> Dict[str, str]:
    return {t[key]: t[value] for t in object.get(tags, {})}


def validate_snapshot(ec2: boto3.session.Session.client, *, snapshot_id: str, image_id: Optional[str]) -> None:  # type: ignore
    if image_id:
        images_res = ec2.describe_images(ImageIds=[image_id])  # type: ignore
        if not len(images_res["Images"]):
            raise Exception(f"no such image {image_id}")

        logger.info(f"making sure that the snapshot {snapshot_id} belongs to the image {image_id}")
        image_info = images_res["Images"][0]
        for block_device in image_info["BlockDeviceMappings"]:
            image_snapshot = block_device.get("Ebs", {}).get("SnapshotId")
            if image_snapshot and snapshot_id == image_snapshot:
                return

    snapshots_res = ec2.describe_snapshots(SnapshotIds=[snapshot_id])  # type: ignore
    if not len(snapshots_res["Snapshots"]):
        raise Exception(f"no such snapshot {snapshot_id}")

    tags = tags_dict(snapshots_res["Snapshots"][0])
    if "Orca" not in tags:
        raise Exception(f"{snapshot_id} is not Orca snapshot")


def handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """Main lambda entrypoint"""
    try:
        logger.info(f"called with: {event=}")

        # input parameters:
        dry_run = event.get("dry_run", False)
        operation = event["operation"]
        role_arn = event.get("role_arn")
        role_external_id = event.get("role_external_id")
        snapshot_id = event["snapshot_id"]
        image_id = event.get("image_id")
        region_name = event["region_name"]
        policy_type = event.get("policy_type")
        is_inaccount = os.environ.get("SCAN_MODE", "inaccount").lower() == "inaccount"
        modify_snapshot_attributes(
            dry_run,
            event,
            image_id,
            is_inaccount,
            operation,
            region_name,
            role_arn,
            role_external_id,
            snapshot_id,
            policy_type,
        )
        return {"result": "ok"}

    except ClientError as e:
        logger.exception("permissions modification failed")
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
        logger.exception("permissions modification failed")
        return {"result": "exception", "exception": json.dumps(str(e)), "backtrace": traceback.format_exc()}


def assert_orca_account(account_id: str) -> None:
    accounts = os.environ["ORCA_SCANNER_ACCOUNTS"].split(",")
    if account_id not in accounts:
        raise Exception(f"security violation: {account_id=} not in accounts list {accounts=}")


def modify_snapshot_attributes(
    dry_run: bool,
    event: Dict[str, Any],
    image_id: Optional[str],
    is_inaccount: bool,
    operation: str,
    region_name: str,
    role_arn: Optional[str],
    role_external_id: Optional[str],
    snapshot_id: str,
    policy_type: Optional[str],
) -> None:
    sts = boto3.client("sts")
    # get the ec2 client of the target account
    client_extras = {}
    if role_arn and role_external_id and policy_type != "target_lambda":
        assumed_role = sts.assume_role(
            RoleArn=role_arn,
            ExternalId=role_external_id,
            RoleSessionName="orca-security-secure-snapshot-share",
        )
        credentials = assumed_role["Credentials"]
        client_extras = dict(
            aws_access_key_id=credentials["AccessKeyId"],
            aws_secret_access_key=credentials["SecretAccessKey"],
            aws_session_token=credentials["SessionToken"],
        )
        account_id = sts.get_caller_identity()["Account"]
    else:
        account_id = event["account_id"]
        if not is_inaccount:
            assert_orca_account(account_id)

    ec2 = boto3.client("ec2", region_name=region_name, **client_extras)
    validate_snapshot(ec2, snapshot_id=snapshot_id, image_id=image_id)
    # add/remove permission for the Service Account to read the snapshot
    ec2.modify_snapshot_attribute(
        Attribute="createVolumePermission",
        SnapshotId=snapshot_id,
        OperationType=operation,
        UserIds=[account_id],
        DryRun=dry_run,
    )
    logger.info(f"operation: {operation} permissions for {snapshot_id} to {account_id} done.")
