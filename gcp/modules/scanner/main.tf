resource "google_project_iam_member" "this" {
  for_each = var.multiple ? [] : toset(concat(local._roles, var.enable_dspm ? local.dspm.target : []))
  project  = var.target_project_id
  role     = each.value
  member   = "serviceAccount:${module.service_accounts.email}"
}

# Enable the gcp APIs from the local._apis_to_enable
resource "google_project_service" "this" {
  for_each           = toset(local._apis_to_enable)
  service            = each.key
  project            = var.scanner_project_id
  disable_on_destroy = false
}

# CREATE ORCA SECURITY ROLE
resource "google_project_iam_custom_role" "this" {
  role_id     = "orca_security_in_account_side_scanner_role_tf"
  title       = "Orca Security In-Account Side Scanner Role Terraform"
  permissions = local._permissions
  project     = var.scanner_project_id
}

# CREATE A SERVICE ACCOUNT
module "service_accounts" {
  source        = "terraform-google-modules/service-accounts/google"
  version       = "~> 4.2"
  project_id    = var.scanner_project_id
  names         = [var.service_account_name]
  display_name  = "Orca Security Side Scanning Service Account Terraform"
  generate_keys = true
  project_roles = local.roles.in_account
}

################################################################################################################################################
#                                                  DSPM                                                                                        #
################################################################################################################################################

# CREATE Orca Security DSPM Side Scanner Role (Project level)
resource "google_project_iam_custom_role" "dspm_scanner_role" {
  count       = var.enable_dspm && !var.multiple ? 1 : 0
  role_id     = var.dspm_target_role_id
  title       = "Orca Security DSPM Side Scanner Role Terraform"
  description = "Orca custom permissions for DSPM side scanner for terraform"
  permissions = local.permissions.dspm_scanner_role
  project     = var.target_project_id
}

resource "google_project_iam_member" "dspm_scanner" {
  for_each = var.enable_dspm ? toset(local.dspm.scanner) : []
  project  = var.scanner_project_id
  role     = each.value
  member   = "serviceAccount:${module.service_accounts.email}"
}