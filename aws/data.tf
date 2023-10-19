locals {
  bucket_name = var.bucket_name
  policy_name = var.deployment_type == "saas" ? var.policy_name : "${var.policy_name}SA"
  role_name   = var.deployment_type == "saas" ? var.role_name : "${var.role_name}SA"

  lambda_keys = [
    "lambda/add_kms_grant.py",
    "lambda/copy_snapshot.py",
    "lambda/create_db_snapshot.py",
    "lambda/create_kms_key.py",
    "lambda/get_kms_key.py",
    "lambda/modify_snapshot_attributes.py",
    "lambda/share_db_snapshot.py",
    "lambda/share_kms_key.py"
  ]

  iam_policies = {
    # General
    view_only_extras_policy = "policies/view_only_extras_policy.json"
    secrets_manager_policy  = "policies/client_secrets_manager_policy.json"
    # Saas 
    policy                        = var.deployment_type == "saas" ? "policies/saas/client_policy.json" : "policies/scanner_account/scanner_to_orca_policy.json"
    rds_snapshot_create_policy    = "policies/saas/rds_scanner/rds_snapshot_create_policy.json"
    rds_snapshot_reencrypt_policy = "policies/saas/rds_scanner/rds_snapshot_reencrypt_policy.json"
    rds_snapshot_share_policy     = "policies/saas/rds_scanner/rds_snapshot_share_policy.json"
    # Scanner Account
    scanner_account_rds_scanning_policy = "policies/scanner_account/client_to_scanner_rds_policy.json"
    lambda_execution_policy             = "policies/scanner_account/lambda_execution_policy.json"
    lambda_extended_policy              = "policies/scanner_account/lambda_extended_policy.json"
    scanner_account_policy              = "policies/scanner_account/scanner_to_orca_policy.json"
    # Target Account 
    target_rds_snapshot_create_policy    = "policies/target_account/rds_snapshot_create_policy.json"
    target_rds_snapshot_reencrypt_policy = "policies/target_account/rds_snapshot_reencrypt_policy.json"
    target_rds_snapshot_share_policy     = "policies/target_account/rds_snapshot_share_policy.json"
    target_account_policy                = "policies/target_account/client_to_orca_policy.json"
    side_scanner_policy                  = "policies/target_account/client_to_scanner_policy.json"
  }

  cloudformation_stack_set = {
    saas      = "cloudformation_stack_set/stack_set_saas.json"
    inaccount = "cloudformation_stack_set/stack_set_inaccount.json"
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_organizations_organization" "this" {
  count = var.deploy_stack_set ? 1 : 0
}
################################################################################################################
#                                           Policy                                                             #
################################################################################################################


data "http" "iam_policy_template" {
  for_each = local.iam_policies
  url    = "${var.backend_url}/api/onboarding/terraform/aws/files?file=${urlencode(each.value)}"
  method = "GET"
}

################################################################################################################
#                                           Lambda                                                             #
################################################################################################################

data "http" "this" {
  count  = length(local.lambda_keys)
  url    = "${var.backend_url}/api/onboarding/terraform/aws/files?file=${urlencode(element(local.lambda_keys, count.index))}"
  method = "GET"
}

resource "local_file" "this" {
  count    = var.deployment_type == "inaccount_scanner_account" ? length(local.lambda_keys) : 0
  content  = data.http.this[count.index].response_body
  filename = ".terraform/${element(local.lambda_keys, count.index)}"
}

################################################################################################################
#                                 CloudFormation Stack Set                                                     #
################################################################################################################

data "http" "cloudformation_stack_set_saas" {
  url    = "${var.backend_url}/api/onboarding/terraform/aws/files?file=${urlencode(local.cloudformation_stack_set.saas)}"
  method = "GET"
}

data "http" "cloudformation_stack_set_inaccount" {
  url    = "${var.backend_url}/api/onboarding/terraform/aws/files?file=${urlencode(local.cloudformation_stack_set.inaccount)}"
  method = "GET"
}