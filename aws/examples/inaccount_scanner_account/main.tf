provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      "created_by" = "terraform"
      "Orca"       = "True"
    }
  }
}

module "orca_aws_onboarding_scanner_account" {
#  local TF module
  source = "../../"

#  production TF module
#  source = "https://api.orcasecurity.io/api/onboarding/terraform?archive=zip&provider=aws"

#  devenv TF module
#  source = "https://orcadev<env_name>-api.devenv<number>.orcasecurity.net/api/onboarding/terraform?archive=zip&provider=aws"

  deployment_type  = "inaccount_scanner_account"
  role_external_id = "2eff7c65-c1ab-42aa-947f-e2cfb3b797bb"
}

output "scanner_account_orca_role_arn" {
  description = "Scanner account role ARN to be used to connect"
  value       = module.orca_aws_onboarding_scanner_account.orca_role_arn
}

