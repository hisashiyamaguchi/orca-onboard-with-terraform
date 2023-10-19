terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.84.0"
    }
  }
}

################################################################################################################################################
#                                                      Basic configuration                                                                     #
################################################################################################################################################

# Enable the gcp APIs from the local._apis_to_enable
resource "google_project_service" "this" {
  for_each           = toset(local._apis_to_enable)
  service            = each.key
  project            = var.target_project_id
  disable_on_destroy = false
}

# CREATE ORCA SECURITY ROLE (Project level)
resource "google_project_iam_custom_role" "this" {
  count       = var.multiple ? 0 : 1
  role_id     = var.role_id
  title       = "Orca Security Side Scanner Role Terraform"
  permissions = local._permissions
  project     = var.target_project_id
}


# CREATE A SERVICE ACCOUNT
module "service_accounts" {
  count         = var.in_account ? 0 : 1
  source        = "terraform-google-modules/service-accounts/google"
  version       = "~> 4.2"
  project_id    = var.target_project_id
  names         = [var.service_account_name]
  display_name  = "Orca Security Side Scanning Service Account Terraform"
  generate_keys = true
  project_roles = var.multiple ? [] : concat(local._roles, local._dspm)
}

# ADD KMS PERMISSIONS TO ENABLE ORCA TO SCAN ENCRYPTED DRIVES (OPTIONAL)
resource "google_project_iam_member" "this" {
  count   = var.enable_kms && !var.multiple ? 1 : 0
  project = var.target_project_id
  role    = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member  = "serviceAccount:service-${var.in_account ? var.scanner_project_number : local.orca_production_project_number}@compute-system.iam.gserviceaccount.com"
}

resource "google_folder_iam_member" "kms" {
  count  = var.multiple && var.folder_id != null && var.enable_kms ? 1 : 0
  folder = var.folder_id
  role   = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member = "serviceAccount:service-${var.in_account ? var.scanner_project_number : local.orca_production_project_number}@compute-system.iam.gserviceaccount.com"
}

resource "google_organization_iam_member" "kms" {
  count  = var.multiple && var.folder_id == null && var.enable_kms ? 1 : 0
  org_id = var.organization_id
  role   = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member = "serviceAccount:service-${var.in_account ? var.scanner_project_number : local.orca_production_project_number}@compute-system.iam.gserviceaccount.com"
}

################################################################################################################################################
#                                                 Organization (connect multiple accounts)                                                     #
################################################################################################################################################

# CREATE ORCA SECURITY ROLE (Organization level)
resource "google_organization_iam_custom_role" "this" {
  count       = var.multiple ? 1 : 0
  role_id     = var.role_id
  org_id      = var.organization_id
  title       = "Orca Security Side Scanner Role Organization Terraform"
  description = "Orca custom permissions for side scanner on organization level for terraform"
  permissions = local._permissions
}

resource "google_organization_iam_member" "this" {
  for_each = var.multiple && var.folder_id == null ? toset(concat(local._roles, local._dspm)) : toset([])
  org_id   = var.organization_id
  role     = each.value
  member   = var.in_account ? "serviceAccount:${module.scanner_account[0].email}" : "serviceAccount:${module.service_accounts[0].email}"
  depends_on = [
    google_organization_iam_custom_role.this
  ]
}

resource "google_folder_iam_member" "this" {
  for_each = var.multiple && var.folder_id != null ? toset(concat(local._roles, local._dspm)) : toset([])
  folder   = var.folder_id
  role     = each.value
  member   = var.in_account ? "serviceAccount:${module.scanner_account[0].email}" : "serviceAccount:${module.service_accounts[0].email}"
  depends_on = [
    google_organization_iam_custom_role.this
  ]
}

################################################################################################################################################
#                                              Create Scanner Account (in account configuration)                                               #
################################################################################################################################################

module "scanner_account" {
  count  = var.in_account ? 1 : 0
  source = "./modules/scanner"

  scanner_project_id   = var.scanner_project_id
  target_project_id    = var.target_project_id
  target_account_role  = var.multiple ? null : google_project_iam_custom_role.this[0].role_id
  multiple             = var.multiple
  service_account_name = var.service_account_name
  enable_dspm          = var.enable_dspm
}

################################################################################################################################################
#                                                  DSPM                                                                                        #
################################################################################################################################################

#Side Scanner Role

# CREATE Orca Security DSPM Side Scanner Role (Project level)
resource "google_project_iam_custom_role" "dspm_scanner_role" {
  count       = var.enable_dspm && !var.multiple && !var.in_account ? 1 : 0
  role_id     = var.dspm_target_role_id
  title       = "Orca Security DSPM Side Scanner Role Terraform"
  description = "Orca custom permissions for DSPM side scanner for terraform"
  permissions = local.permissions.dspm_scanner_role
  project     = var.target_project_id
}

# CREATE ORCA SECURITY DSPM Side Scanner Role (Organization level)
resource "google_organization_iam_custom_role" "dspm" {
  count       = var.enable_dspm && var.multiple ? 1 : 0
  role_id     = var.dspm_org_target_role_id
  org_id      = var.organization_id
  title       = "Orca Security DSPM Side Scanner Role Terraform"
  description = "Orca custom permissions for DSPM side scanner for terraform"
  permissions = local.permissions.dspm_scanner_role
}

#Backup Retrieval Role

# Project level
# CREATE Orca Security DSPM Backup Retrieval Role (Project level)
resource "google_project_iam_custom_role" "dspm_backup_role" {
  count       = var.enable_dspm && !var.multiple ? 1 : 0
  role_id     = var.dspm_vendor_role_id
  title       = "Orca Security DSPM Backup Retrieval Terraform"
  description = "Orca custom permissions for DSPM Backup retrieval for terraform"
  permissions = local.permissions.dspm_backup_role
  project     = var.target_project_id
}

resource "google_project_iam_member" "dspm_backup" {
  count   = var.enable_dspm && !var.in_account && !var.multiple ? 1 : 0
  project = var.target_project_id
  role    = "projects/${var.target_project_id}/roles/${google_project_iam_custom_role.dspm_backup_role[0].role_id}"
  member  = local.orca_production_sa
}

# Organization level
# CREATE Orca Security DSPM Backup Retrieval Role (Organization level)
resource "google_organization_iam_custom_role" "dspm_backup_role" {
  count       = var.enable_dspm && var.multiple && !var.in_account ? 1 : 0
  role_id     = var.dspm_org_vendor_role_id
  org_id      = var.organization_id
  title       = "Orca Security DSPM Backup Retrieval Terraform"
  description = "Orca custom permissions for DSPM Backup retrieval for terraform"
  permissions = local.permissions.dspm_backup_role
}

# IAM Member Organization level
resource "google_organization_iam_member" "dspm_backup" {
  count  = var.multiple && var.folder_id == null && var.enable_dspm && !var.in_account ? 1 : 0
  org_id = var.organization_id
  role   = "organizations/${var.organization_id}/roles/${google_organization_iam_custom_role.dspm_backup_role[0].role_id}"
  member = local.orca_production_sa
}

# IAM Member Folder level
resource "google_folder_iam_member" "dspm_backup" {
  count  = var.multiple && var.folder_id != null && var.enable_dspm && !var.in_account ? 1 : 0
  folder = var.folder_id
  role   = "organizations/${var.organization_id}/roles/${google_organization_iam_custom_role.dspm_backup_role[0].role_id}"
  member = local.orca_production_sa
}






