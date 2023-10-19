################################################################################################################
#                                          StackSet                                                            #
################################################################################################################

resource "aws_cloudformation_stack_set" "this" {
  count            = var.deploy_stack_set ? 1 : 0
  name             = "OrcaSecurityStackSet"
  permission_model = "SERVICE_MANAGED"
  call_as          = "SELF"
  description      = "Orca Organization-level stack set. This stack set will automatically deploy Orca permissions on OU or all Organization's accounts."
  capabilities     = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]

  auto_deployment {
    enabled                          = true
    retain_stacks_on_account_removal = false
  }

  parameters = var.deployment_type == "inaccount_target_account" ? {
    VendorAccountId = var.vendor_account_id
    ExternalId          = var.role_external_id
    SecretManagerAccess = var.secrets_manager_access
    DeployRdsScanner    = var.enable_dspm
    RoleName            = local.role_name
    #ScannerRoleName = 
    PolicyName = local.policy_name
    #ScannerPolicyName =
    ScannerAccountId = var.inaccount_scanner_account_id
    } : {
    VendorAccountId = var.vendor_account_id
    ExternalId          = var.role_external_id
    SecretManagerAccess = var.secrets_manager_access
    RoleName            = local.role_name
    PolicyName          = local.policy_name
    DeployRdsScanner    = var.enable_dspm
  }

  template_body = (var.deployment_type == "inaccount_target_account" ? data.http.cloudformation_stack_set_inaccount.response_body : data.http.cloudformation_stack_set_saas.response_body)
}

resource "aws_cloudformation_stack_set_instance" "this" {
  count = var.deploy_stack_set ? 1 : 0
  deployment_targets {
    organizational_unit_ids = var.organizational_unit_ids == null ? [data.aws_organizations_organization.this[0].roots[0].id] : var.organizational_unit_ids
  }

  region         = data.aws_region.current.name
  stack_set_name = aws_cloudformation_stack_set.this[0].name
}