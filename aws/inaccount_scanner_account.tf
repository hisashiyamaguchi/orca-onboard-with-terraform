################################################################################################################
#                                          Scanner Account                                                     #
################################################################################################################

################################################### Role #######################################################

resource "aws_iam_service_linked_role" "scanner_account_rds_service_linked_role" {
    count = (var.enable_dspm && var.create_rds_service_linked_role) ? 1 : 0
    description = "Allows Amazon RDS to manage AWS resources on your behalf"
    aws_service_name = "rds.amazonaws.com"
}

resource "aws_iam_role" "scanner_account_add_kms_grant_role" {
  count = var.deployment_type == "inaccount_scanner_account" ? 1 : 0
  name  = "OrcaSecurityAddKmsGrantRole"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : ["lambda.amazonaws.com"]
        },
        "Action" : ["sts:AssumeRole"]
      }
    ]
  })
  inline_policy {
    name = "OrcaExtendedRole"
    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "sts:GetCallerIdentity"
          ],
          "Resource" : "*"
        },
        {
          "Sid" : "kmsadministration",
          "Effect" : "Allow",
          "Action" : [
            "kms:Create*",
            "kms:List*"
          ],
          "Resource" : "*"
        }
      ]
    })
  }
}

resource "aws_iam_role" "scanner_account_common_lambda_execution_role" {
  count = var.deployment_type == "inaccount_scanner_account" ? 1 : 0
  name  = "OrcaSecurityCommonLambdaExecutionRole"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : ["lambda.amazonaws.com"]
        },
        "Action" : ["sts:AssumeRole"]
      }
    ]
  })
}

resource "aws_iam_role" "scanner_account_create_kms_key_role" {
  count = var.deployment_type == "inaccount_scanner_account" ? 1 : 0
  name  = "OrcaSecurityCreateKmsKeyRole"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : ["lambda.amazonaws.com"]
        },
        "Action" : ["sts:AssumeRole"]
      }
    ]
  })
  inline_policy {
    name = "OrcaExtendedRole"
    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : [
            "sts:GetCallerIdentity"
          ],
          "Resource" : "*",
          "Effect" : "Allow"
        },
        {
          "Action" : [
            "kms:Create*",
            "kms:TagResource",
            "kms:Describe*",
            "kms:Enable*",
            "kms:List*",
            "kms:Put*",
            "kms:Update*",
            "kms:Revoke*",
            "kms:Disable*",
            "kms:Get*",
            "kms:Delete*",
            "kms:ScheduleKeyDeletion",
            "kms:CancelKeyDeletion"
          ],
          "Resource" : "*",
          "Effect" : "Allow",
          "Sid" : "kmsadministration"
        }
      ]
    })
  }
}

################################################### Policy  ####################################################

resource "aws_iam_policy" "scanner_account_rds_scanning_policy" {
  count       = var.deployment_type == "inaccount_scanner_account" ? 1 : 0
  policy      = replace(data.http.iam_policy_template["scanner_account_rds_scanning_policy"].response_body, "$${partition}" , var.aws_partition)
  name        = "OrcaScannerAccountRdsScanningPolicy"
  description = "Orca Security RDS Scanner Policy"
}

resource "aws_iam_policy" "scanner_account_lambda_execution_policy" {
  count       = var.deployment_type == "inaccount_scanner_account" ? 1 : 0
  policy      = replace(data.http.iam_policy_template["lambda_execution_policy"].response_body, "$${partition}" , var.aws_partition)
  name        = "OrcaSecurityLambdaExecutionPolicy"
  description = "Orca Security Lambda Execution Policy"
}

resource "aws_iam_policy" "scanner_account_lambda_extended_policy" {
  count       = var.deployment_type == "inaccount_scanner_account" ? 1 : 0
  policy      = replace(data.http.iam_policy_template["lambda_extended_policy"].response_body, "$${partition}" , var.aws_partition)
  name        = "OrcaSecurityLambdaExtendedPolicy"
  description = "Orca Security Lambda Extended Policy"
}

############################################# Policy Attachment ################################################

resource "aws_iam_role_policy_attachment" "scanner_account_add_kms_grant_attach" {
  count      = var.deployment_type == "inaccount_scanner_account" ? 1 : 0
  role       = aws_iam_role.scanner_account_add_kms_grant_role[0].name
  policy_arn = aws_iam_policy.scanner_account_lambda_execution_policy[0].arn
}

resource "aws_iam_role_policy_attachment" "scanner_account_common_lambda_execution_attach_1" {
  count      = var.deployment_type == "inaccount_scanner_account" ? 1 : 0
  role       = aws_iam_role.scanner_account_common_lambda_execution_role[0].name
  policy_arn = aws_iam_policy.scanner_account_lambda_execution_policy[0].arn
}

resource "aws_iam_role_policy_attachment" "scanner_account_common_lambda_execution_attach_2" {
  count      = var.deployment_type == "inaccount_scanner_account" ? 1 : 0
  role       = aws_iam_role.scanner_account_common_lambda_execution_role[0].name
  policy_arn = aws_iam_policy.scanner_account_lambda_extended_policy[0].arn
}

resource "aws_iam_role_policy_attachment" "scanner_account_create_kms_key_attach" {
  count      = var.deployment_type == "inaccount_scanner_account" ? 1 : 0
  role       = aws_iam_role.scanner_account_create_kms_key_role[0].name
  policy_arn = aws_iam_policy.scanner_account_lambda_execution_policy[0].arn
}

resource "aws_iam_role_policy_attachment" "scanner_account_attach" {
  count      = (var.enable_dspm && var.deployment_type == "inaccount_scanner_account") ? 1 : 0
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.scanner_account_rds_scanning_policy[0].arn
}

################################################# Lambda ######################################################

locals {
  lambdas = {
    OrcaSecurityAddKmsGrant = {
      source_file = ".terraform/lambda/add_kms_grant.py"
      lambda_role = var.deployment_type == "inaccount_scanner_account" ? aws_iam_role.scanner_account_add_kms_grant_role[0].arn : ""
      alias       = "v3"
      env_vars    = {}
    },
    OrcaSecurityCopySnapshot = {
      source_file = ".terraform/lambda/copy_snapshot.py"
      lambda_role = var.deployment_type == "inaccount_scanner_account" ? aws_iam_role.scanner_account_common_lambda_execution_role[0].arn : ""
      alias       = "v4"
      env_vars    = {}
    },
    OrcaSecurityCreateDBSnapshot = {
      source_file = ".terraform/lambda/create_db_snapshot.py"
      lambda_role = var.deployment_type == "inaccount_scanner_account" ? aws_iam_role.scanner_account_common_lambda_execution_role[0].arn : ""
      alias       = "v1"
      env_vars    = {}
    },
    OrcaSecurityCreateKmsKey = {
      source_file = ".terraform/lambda/create_kms_key.py"
      lambda_role = var.deployment_type == "inaccount_scanner_account" ? aws_iam_role.scanner_account_create_kms_key_role[0].arn : ""
      alias       = "v2"
      env_vars    = tomap({
        "ALLOW_KMS_KEYS_FOR_RDS_SCANNING" = var.enable_dspm
        "ORCA_SCANNER_ROLE_ARN" = aws_iam_role.role.arn
      })
    },
    OrcaSecurityGetKmsKey = {
      source_file = ".terraform/lambda/get_kms_key.py"
      lambda_role = var.deployment_type == "inaccount_scanner_account" ? aws_iam_role.scanner_account_common_lambda_execution_role[0].arn : ""
      alias       = "v2"
      env_vars    = {}
    },
    OrcaSecurityModifySnapshot = {
      source_file = ".terraform/lambda/modify_snapshot_attributes.py"
      lambda_role = var.deployment_type == "inaccount_scanner_account" ? aws_iam_role.scanner_account_common_lambda_execution_role[0].arn : ""
      alias       = "v2"
      env_vars    = {}
    },
    OrcaSecurityShareDBSnapshot = {
      source_file = ".terraform/lambda/share_db_snapshot.py"
      lambda_role = var.deployment_type == "inaccount_scanner_account" ? aws_iam_role.scanner_account_common_lambda_execution_role[0].arn : ""
      alias       = "v1"
      env_vars    = {}
    },
    OrcaSecurityShareKmsKey = {
      source_file = ".terraform/lambda/share_kms_key.py"
      lambda_role = var.deployment_type == "inaccount_scanner_account" ? aws_iam_role.scanner_account_common_lambda_execution_role[0].arn : ""
      alias       = "v4"
      env_vars    = {}
    }
  }
}

module "lambda" {
  source   = "./modules/lambda"
  for_each = (var.deployment_type == "inaccount_scanner_account" ? local.lambdas : {})

  function_name = each.key
  source_file   = each.value.source_file
  lambda_role   = each.value.lambda_role
  env_vars      = each.value.env_vars
  alias         = each.value.alias

  depends_on = [
    local_file.this
  ]
}
