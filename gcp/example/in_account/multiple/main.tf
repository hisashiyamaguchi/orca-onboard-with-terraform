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

  # Uncomment role_id or service_account_name to override the default name if needed
  # role_id = "<Custom Role ID>"
  # service_account_name = "<Service Account Name>"
  # dspm_org_target_role_id = "<Custom DSPM Target Role ID>"

  # In Acoount multiple
  in_account             = true
  multiple               = true
  scanner_project_id     = "<Scanner Project ID>"
  scanner_project_number = "<Scanner Project Number>"
  organization_id        = "<Organization ID>"
  folder_id              = "<Folder ID>"
}

################################################################## 
#                              Output                            # 
################################################################## 

output "service_account_json_key" {
  value     = module.orca-gcp-onboarding.service_account_json_key
  sensitive = true
} 

output "gcp_organization_id" {
  description = "GCP Organization ID."
  value       = module.orca-gcp-onboarding.gcp_organization_id
}

output "scanner_project_id" {
  description = "Scanner Account Project ID."
  value       = module.orca-gcp-onboarding.scanner_project_id
}
