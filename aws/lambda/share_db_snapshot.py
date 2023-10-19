import json
import logging
import os
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
        role_arn = event["role_arn"]
        role_external_id = event["role_external_id"]
        snapshot_arn = event["snapshot_arn"]
        region_name = event["region_name"]
        account_id = event["account_id"]
        operation = event.get("operation", "share")
        policy_type = event.get("policy_type")
        is_inaccount = os.environ.get("SCAN_MODE", "inaccount").lower() == "inaccount"

        modify_db_snapshot_attributes(
            is_inaccount,
            account_id,
            region_name,
            role_arn,
            role_external_id,
            operation,
            snapshot_arn,
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


def modify_db_snapshot_attributes(
    is_inaccount: bool,
    account_id: str,
    region_name: str,
    role_arn: Optional[str],
    role_external_id: Optional[str],
    operation: str,
    snapshot_arn: str,
    policy_type: Optional[str],
) -> None:
    sts = boto3.client("sts")
    # get the ec2 client of the target account
    client_extras = {}

    # Case 1: The lambda's is in the scanner account
    # - we need to assume a role in the target account.
    if role_arn and role_external_id and policy_type != "target_lambda":
        assumed_role = sts.assume_role(
            RoleArn=role_arn,
            ExternalId=role_external_id,
            RoleSessionName="orca-security-secure-db-snapshot-share",
        )
        credentials = assumed_role["Credentials"]
        client_extras = dict(
            aws_access_key_id=credentials["AccessKeyId"],
            aws_secret_access_key=credentials["SecretAccessKey"],
            aws_session_token=credentials["SessionToken"],
        )
        # Ignore the account_id parameter, and use the current (scanner) account's id instead.
        account_id = sts.get_caller_identity()["Account"]

    # Case 2: The lambda is in the target account, using SaaS mode
    # - we need to verify the account_id parameter specifies an account owned by Orca.
    elif not is_inaccount:
        assert_orca_account(account_id)

    # Case 3: The lambda is in the target account, using OrcaPod mode
    # - in this case target account == scanner account, so there's the snapshot is already available.
    else:
        logger.info(f"operation: {operation} DB snapshot {snapshot_arn} with {account_id} skipped.")
        return

    rds = boto3.client("rds", region_name=region_name, **client_extras)

    resource_type = snapshot_arn.split(":")[5]
    snapshot_id = snapshot_arn.split(":")[6]
    if resource_type == "snapshot":
        rds.modify_db_snapshot_attribute(
            DBSnapshotIdentifier=snapshot_id,
            AttributeName="restore",
            ValuesToAdd=[account_id] if operation == "share" else [],
            ValuesToRemove=[account_id] if operation == "unshare" else [],
        )
    else:
        assert resource_type == "cluster-snapshot"
        rds.modify_db_cluster_snapshot_attribute(
            DBClusterSnapshotIdentifier=snapshot_id,
            AttributeName="restore",
            ValuesToAdd=[account_id] if operation == "share" else [],
            ValuesToRemove=[account_id] if operation == "unshare" else [],
        )
    logger.info(f"operation: {operation} on DB snapshot {snapshot_arn} with {account_id} done.")
