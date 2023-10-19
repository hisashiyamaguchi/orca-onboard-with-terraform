import json
import logging
import traceback
from typing import Any, Dict, List, Optional

import boto3
from botocore.exceptions import ClientError

logger = logging.getLogger("orca")
logger.setLevel(logging.INFO)


def to_key_value_list(d: Dict[str, str]) -> List[Dict[str, str]]:
    return [{"Key": k, "Value": v} for k, v in d.items()]


def tags_dict(object: Dict[str, Any], key: str = "Key", value: str = "Value", tags: str = "Tags") -> Dict[str, str]:
    return {t[key]: t[value] for t in object.get(tags, {})}


def json_normalize_response(resp: Dict[str, Any]) -> Dict[str, Any]:
    return json.loads(json.dumps(resp, default=str))  # type: ignore


def create_db_snapshot(
    role_arn: Optional[str],
    role_external_id: Optional[str],
    source_arn: str,
    target_snapshot_name: str,
    region: str,
    kms_key_id: Optional[str],
    policy_type: Optional[str],
    snapshot_tags: Dict[str, str],
) -> Dict[str, Any]:
    """Initiate a copy of an encrypted snapshot with a new kms key"""

    logger.info(f"Creating snapshot from [{source_arn}] {role_arn=} {role_external_id=} {region=} {kms_key_id=}")

    sts = boto3.client("sts")
    # get the target account's ec2 client
    client_init_extras = {}
    if role_arn and role_external_id and policy_type != "target_lambda":
        assumed_role = sts.assume_role(
            RoleArn=role_arn,
            ExternalId=role_external_id,
            RoleSessionName="orca-security-secure-create-db-snapshot",
        )
        credentials = assumed_role["Credentials"]
        client_init_extras = dict(
            aws_access_key_id=credentials["AccessKeyId"],
            aws_secret_access_key=credentials["SecretAccessKey"],
            aws_session_token=credentials["SessionToken"],
        )

    rds = boto3.client(
        "rds",
        region_name=region,
        **client_init_extras,
    )
    resource_type = source_arn.split(":")[5]
    if resource_type == "snapshot":
        response: Dict[str, Any] = rds.copy_db_snapshot(
            SourceDBSnapshotIdentifier=source_arn,
            TargetDBSnapshotIdentifier=target_snapshot_name,
            Tags=to_key_value_list(snapshot_tags),
            **({"KmsKeyId": kms_key_id} if kms_key_id else {}),
        )
    elif resource_type == "cluster-snapshot":
        response = rds.copy_db_cluster_snapshot(
            SourceDBClusterSnapshotIdentifier=source_arn,
            TargetDBClusterSnapshotIdentifier=target_snapshot_name,
            Tags=to_key_value_list(snapshot_tags),
            **({"KmsKeyId": kms_key_id} if kms_key_id else {}),
        )
    elif resource_type == "db":
        response = rds.create_db_snapshot(
            DBInstanceIdentifier=source_arn,
            DBSnapshotIdentifier=target_snapshot_name,
            Tags=to_key_value_list(snapshot_tags),
        )
    else:
        assert resource_type == "cluster"
        response = rds.create_db_cluster_snapshot(
            DBClusterIdentifier=source_arn,
            DBClusterSnapshotIdentifier=target_snapshot_name,
            Tags=to_key_value_list(snapshot_tags),
        )

    if resource_type in {"snapshot", "db"}:
        logger.info(f'Created DB snapshot {response["DBSnapshot"]["DBSnapshotIdentifier"]} from {source_arn}')
    else:
        logger.info(
            f'Created DB snapshot {response["DBClusterSnapshot"]["DBClusterSnapshotIdentifier"]} from {source_arn}'
        )
    return json_normalize_response(response)


def handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """Main lambda entrypoint"""
    try:
        sts = boto3.client("sts")
        account_id = sts.get_caller_identity()["Account"]
        logger.info(f"called with: {event=} {account_id=}")

        # input parameters
        role_arn = event.get("role_arn")
        role_external_id = event.get("role_external_id")
        region_name = event["region_name"]
        source_arn = event["source_arn"]
        target_snapshot_name = event["target_snapshot_name"]
        kms_key_id = event.get("kms_key_id")
        policy_type = event.get("policy_type")
        snapshot_tags = event.get("snapshot_tags", {})
        # perform the copy
        response = create_db_snapshot(
            role_arn,
            role_external_id,
            source_arn,
            target_snapshot_name,
            region_name,
            kms_key_id,
            policy_type,
            snapshot_tags,
        )
        return {"result": "ok", "response": response}

    except ClientError as e:
        logger.exception("db snapshot copy failed")
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
