################################################################## 
#                              Locals                            # 
################################################################## 
locals {
  provider = {
    project_id = "<Project ID>"
  }
}

################################################################## 
#                              Provider                          # 
################################################################## 

provider "google" {
  project = local.provider.project_id
}

################################################################## 
#                              Module                            # 
################################################################## 

module "orca-gcp-onboarding" {
#  local TF module
 source = "../../../"

#  production TF module
#  source = "https://api.orcasecurity.io/api/onboarding/terraform?archive=zip&provider=gcp"

#  devenv TF module
#  source = "https://orcadev<env_name>-api.devenv<number>.orcasecurity.net/api/onboarding/terraform?archive=zip&provider=gcp"

  target_project_id = local.provider.project_id

  # Uncomment role_id or service_account_name to override the default name if needed
  # role_id = "<Custom Role ID>"
  # service_account_name = "<Service Account Name>"
  # dspm_org_target_role_id = "<Custom DSPM Target Role ID>"

  # In Acoount
  in_account             = true
  scanner_project_id     = "<Scanner Project ID>"
  scanner_project_number = "<Scanner Project Number>"
}

################################################################## 
#                              Output                            # 
################################################################## 

output "service_account_json_key" {
  value     = module.orca-gcp-onboarding.service_account_json_key
  sensitive = true
} 

output "target_project_id" {
  description = "Target Project ID that will be onboarded."
  value       = module.orca-gcp-onboarding.target_project_id
}

output "scanner_project_id" {
  description = "Scanner Account Project ID."
  value       = module.orca-gcp-onboarding.scanner_project_id
}
