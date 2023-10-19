import json
import logging
import os
import traceback
from typing import Any, Dict, List

import boto3
from botocore.exceptions import ClientError

logger = logging.getLogger("orca")
logger.setLevel(logging.INFO)


def get_existing_grants(region_name: str, kms_key: str) -> List[Dict[str, Any]]:
    """
    Get exising grants of a kms key
    """
    kms = boto3.client("kms", region_name=region_name)
    paginator = kms.get_paginator("list_grants")
    page_iterator = paginator.paginate(KeyId=kms_key)
    existing_grants = []
    for page in page_iterator:
        existing_grants += page.get("Grants", [])
    return existing_grants


def add_kms_grant(account_id: str, region_name: str, kms_key: str, partition: str) -> bool:
    """
    Adds kms grant to the Spot Instances Service Principal of the Service Account
    """
    operations = [
        "Encrypt",
        "Decrypt",
        "ReEncryptFrom",
        "ReEncryptTo",
        "GenerateDataKey",
        "GenerateDataKeyWithoutPlaintext",
        "DescribeKey",
        "CreateGrant",
    ]

    # try to locate existing grant
    kms = boto3.client("kms", region_name=region_name)
    grantee_principal = (
        f"arn:{partition}:iam::{account_id}:role/aws-service-role/spot.amazonaws.com/AWSServiceRoleForEC2Spot"
    )
    grants = get_existing_grants(region_name, kms_key)

    grant_map = {grant.get("GranteePrincipal", "").lower(): grant for grant in grants}
    if grantee_principal.lower() in grant_map:
        grant = grant_map[grantee_principal.lower()]
        if set(operations) == set(grant["Operations"]):
            logger.info(f"grant {grant['GrantId']} already exists")
            return True

    # create the grant for the Spot Instances Service Principal
    logger.info(f"{kms_key}: creating grant for {grantee_principal}")

    response = kms.create_grant(
        KeyId=kms_key,
        GranteePrincipal=grantee_principal,
        Operations=operations,
        Name=f"Automatically-generated-orca-grant-to-{account_id}",
    )

    logger.info(f"created grant {response['GrantId']} {kms_key} to {grantee_principal}")

    return False


def handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """Main lambda entrypoint"""
    try:
        # input parameters:
        kms_key_id = event["kms_key_id"]
        region_name = event["region_name"]
        is_inaccount = os.environ.get("SCAN_MODE", "inaccount").lower() == "inaccount"

        caller_identity = boto3.client("sts").get_caller_identity()
        account_id = caller_identity["Account"]
        partition = caller_identity["Arn"].split(":")[1]

        # get the account number of the Service Account
        if not is_inaccount:
            target_account_id = event["target_account_id"]
            allowed_accounts = os.environ["ORCA_SCANNER_ACCOUNTS"].split(",")
            if target_account_id not in allowed_accounts:
                raise Exception(f"do not allow to share with target account {target_account_id} {allowed_accounts=}")
            account_id = target_account_id

        logger.info(f"called with: {event=} {account_id=}")

        # add kms grant
        existing_grant = add_kms_grant(account_id, region_name, kms_key_id, partition)
        logger.info(f"added grant for {account_id} {kms_key_id=}")
        return {"result": "ok", "existing_grant": existing_grant}

    except ClientError as e:
        logger.exception("add kms grant failed")
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
        logger.exception("add kms grant failed")
        return {"result": "exception", "exception": json.dumps(str(e)), "backtrace": traceback.format_exc()}
