import json
import logging
import os
import traceback
from typing import Any, Dict, List, Sequence

import boto3

logger = logging.getLogger("orca")
logger.setLevel(logging.INFO)


def get_orca_scanner_role_arn() -> str:
    return os.environ.get("ORCA_SCANNER_ROLE_ARN", "*")


def kms_for_rds_allowed() -> bool:
    return os.environ.get("ALLOW_KMS_KEYS_FOR_RDS_SCANNING", "false").lower() == "true"


def build_kms_common_policy_statements(partition: str, scanner: str, target: str) -> List[Dict[str, Any]]:
    return [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {"AWS": [f"arn:{partition}:iam::{scanner}:root"]},
            "Action": "kms:*",
            "Resource": "*",
        }
    ]


def build_kms_ec2_policy_statements(partition: str, scanner: str, target: str) -> List[Dict[str, Any]]:
    return [
        {
            "Sid": "Allow usage of the key",
            "Effect": "Allow",
            "Principal": {"AWS": f"arn:{partition}:iam::{target}:root"},
            "Action": ["kms:Encrypt", "kms:Decrypt", "kms:ReEncrypt*", "kms:GenerateDataKey*", "kms:DescribeKey"],
            "Resource": "*",
        },
        {
            "Sid": "Allow attachment of persistent resources",
            "Effect": "Allow",
            "Principal": {"AWS": f"arn:{partition}:iam::{target}:root"},
            "Action": ["kms:CreateGrant", "kms:ListGrants", "kms:RevokeGrant"],
            "Resource": "*",
            "Condition": {"Bool": {"kms:GrantIsForAWSResource": "true"}},
        },
        {
            "Sid": "Allow service role use of the key",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    f"arn:{partition}:iam::{scanner}:role/aws-service-role/spot.amazonaws.com/AWSServiceRoleForEC2Spot"
                ]
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:DescribeKey",
            ],
            "Resource": "*",
        },
        {
            "Sid": "Allow service role attachment of persistent resources",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    f"arn:{partition}:iam::{scanner}:role/aws-service-role/spot.amazonaws.com/AWSServiceRoleForEC2Spot"
                ]
            },
            "Action": ["kms:CreateGrant", "kms:ListGrants", "kms:RevokeGrant"],
            "Resource": "*",
            "Condition": {"Bool": {"kms:GrantIsForAWSResource": "true"}},
        },
    ]


def build_kms_rds_policy_statements(partition: str, scanner: str, target: str) -> List[Dict[str, Any]]:
    return [
        {
            "Sid": "Allow access through RDS for principals in the account that are authorized to use RDS",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    get_orca_scanner_role_arn(),
                    f"arn:{partition}:iam::{scanner}:role/aws-service-role/rds.amazonaws.com/AWSServiceRoleForRDS",
                ]
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:CreateGrant",
                "kms:ListGrants",
                "kms:DescribeKey",
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {"kms:CallerAccount": scanner},
                "StringLike": {"kms:ViaService": "rds.*.amazonaws.com"},
            },
        },
        {
            "Sid": "CreateGrant for DB snapshot re-encryption",
            "Effect": "Allow",
            "Principal": {"AWS": f"arn:{partition}:iam::{target}:root"},
            "Action": "kms:CreateGrant",
            "Resource": "*",
            "Condition": {
                "ForAllValues:StringLike": {
                    "kms:GrantOperations": [
                        "DescribeKey",
                        "Decrypt",
                        "Encrypt",
                        "GenerateDataKeyWithoutPlaintext",
                        "CreateGrant",
                        "RetireGrant",
                    ]
                },
                "Bool": {"kms:GrantIsForAWSResource": True},
                "StringLike": {"kms:ViaService": "rds.*.amazonaws.com"},
            },
        },
        {
            "Sid": "DescribeKey for DB snapshot re-encryption",
            "Effect": "Allow",
            "Principal": {"AWS": f"arn:{partition}:iam::{target}:root"},
            "Action": "kms:DescribeKey",
            "Resource": "*",
            "Condition": {
                "StringLike": {"kms:ViaService": "rds.*.amazonaws.com"},
            },
        },
    ]


def build_kms_policy(partition: str, scanner: str, target: str, services: Sequence[str]) -> str:
    """Create kms policy document for the scanner and for the target"""

    statements = build_kms_common_policy_statements(partition, scanner, target)
    if "EBS" in services:
        statements += build_kms_ec2_policy_statements(partition, scanner, target)
    if "RDS" in services:
        if not kms_for_rds_allowed():
            raise Exception(
                "Creation of KMS keys for RDS scanning is not enabled for this lambda. "
                "To enable it, set `ALLOW_KMS_KEYS_FOR_RDS_SCANNING=true` in the lambda's environment variables."
            )
        statements += build_kms_rds_policy_statements(partition, scanner, target)

    policy = {
        "Id": f"key-policy-{target}",
        "Version": "2012-10-17",
        "Statement": statements,
    }

    return json.dumps(policy)


def handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """Main lambda entrypoint"""
    try:
        caller_identity = boto3.client("sts").get_caller_identity()
        account_id = caller_identity["Account"]
        partition = caller_identity["Arn"].split(":")[1]
        logger.info(f"called with: {event=} {account_id=}")

        # input parameters:
        target_provider_id = event["target"]
        key_tags = event["tags"]
        region_name = event["region_name"]
        services = list(event.get("allowed_services", ["EBS"]))

        # get kms client
        kms = boto3.client("kms", region_name=region_name)

        # create a new key for sharing with the target account
        response = kms.create_key(
            Description=f"kms_for_{target_provider_id}",
            Policy=build_kms_policy(partition, account_id, target_provider_id, services=services),
            Tags=key_tags,
        )
        kms_key_id = response["KeyMetadata"]["Arn"]
        kms.enable_key_rotation(KeyId=kms_key_id)

        logger.info(f"op: {target_provider_id} {kms_key_id=}")
        return {"result": "ok", "kms_key_id": kms_key_id}

    except Exception as e:
        logger.exception("permissions modification failed")
        return {"result": "exception", "exception": json.dumps(str(e)), "backtrace": traceback.format_exc()}
