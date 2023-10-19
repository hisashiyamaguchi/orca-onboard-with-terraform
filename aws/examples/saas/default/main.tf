provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      "created_by" = "terraform"
      "Orca"       = "True"
    }
  }
}

module "orca_aws_onboarding_saas" {
  #  local TF module
  source = "../../../"

#  production TF module
#  source = "https://api.orcasecurity.io/api/onboarding/terraform?archive=zip&provider=aws"

#  devenv TF module
#  source = "https://orcadev<env_name>-api.devenv<number>.orcasecurity.net/api/onboarding/terraform?archive=zip&provider=aws"

  deployment_type  = "saas"
  role_external_id = "38a0f818-a3e5-420f-ad35-0404030a6c77"
}

output "orca_role_arn" {
  description = "Role ARN to be used to onboard"
  value       = module.orca_aws_onboarding_saas.orca_role_arn
}

