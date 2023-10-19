import json
import logging
import traceback
from typing import Any, Dict, Optional

import boto3
from botocore.exceptions import ClientError

logger = logging.getLogger("orca")
logger.setLevel(logging.INFO)


def handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """Main lambda entrypoint"""
    try:
        logger.info(f"called with: {event=}")

        # input parameters:
        role_arn = event.get("role_arn")
        external_id = event.get("role_external_id")
        snapshot_id = event["snapshot_id"]
        region_name = event["region_name"]
        policy_type = event.get("policy_type")
        kms_key_id = get_kms_key(external_id, region_name, role_arn, snapshot_id, policy_type)
        return {"result": "ok", "kms_key_id": kms_key_id}

    except ClientError as e:
        logger.exception("describe snapshots failed")
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
        logger.exception("describe snapshots failed")
        return {"result": "exception", "exception": json.dumps(str(e)), "backtrace": traceback.format_exc()}


def get_kms_key(
    external_id: Optional[str],
    region_name: str,
    role_arn: Optional[str],
    snapshot_id: str,
    policy_type: Optional[str],
) -> str:
    sts = boto3.client("sts")
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
    # get the kms key id
    response = boto3.client("ec2", region_name=region_name, **client_extras).describe_snapshots(
        SnapshotIds=[snapshot_id]
    )
    kms_key_id: str = response["Snapshots"][0]["KmsKeyId"]

    return kms_key_id
