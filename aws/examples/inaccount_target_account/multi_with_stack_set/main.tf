

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      "created_by" = "terraform"
      "Orca"       = "True"
    }
  }
}

module "orca_aws_onboarding_target_account" {
#  local TF module
  source = "../../../"

#  production TF module
#  source = "https://api.orcasecurity.io/api/onboarding/terraform?archive=zip&provider=aws"

#  devenv TF module
#  source = "https://orcadev<env_name>-api.devenv<number>.orcasecurity.net/api/onboarding/terraform?archive=zip&provider=aws"

  deployment_type              = "inaccount_target_account"
  inaccount_scanner_account_id = "<Scanner Account ID>"
  role_external_id             = "<External ID>"
  deploy_stack_set             = true

  # Optional parameters
  # organizational_unit_ids = ["ou1","ou2","ou3"]
}

output "target_account_orca_role_arn" {
  description = "Target account role ARN to be used to connect"
  value       = module.orca_aws_onboarding_target_account.orca_role_arn
}


