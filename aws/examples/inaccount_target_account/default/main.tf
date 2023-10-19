

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
  role_external_id             = "<External ID>"
  inaccount_scanner_account_id = "<Scanner Account ID>"
}

output "target_account_orca_role_arn" {
  description = "Target account role ARN to be used to connect"
  value       = module.orca_aws_onboarding_target_account.orca_role_arn
}

output "orca_side_scanner_role_arn" {
  description = "Side Scanner Role ARN to be used to connect"
  value       = module.orca_aws_onboarding_target_account.orca_side_scanner_role_arn
}


