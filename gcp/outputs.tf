output "service_account_json_key" {
  description = "Service Account Key (for single use)."
  sensitive   = true
  value       = var.in_account ? module.scanner_account[0].key : module.service_accounts[0].key
}

# default onboarding
output "target_project_id" {
  description = "Target Project ID that will be onboarded."
  value       = var.target_project_id
}

# multi onboarding
output "gcp_organization_id" {
  description = "GCP Organization ID."
  value       = var.organization_id
}

# in-account onboarding
output "scanner_project_id" {
  description = "Scanner Account Project ID."
  value       = var.scanner_project_id
}
