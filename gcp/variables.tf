################################################################################################################################################
#                                                      Basic configuration                                                                     #
################################################################################################################################################

variable "target_project_id" {
  description = "Provide the Project ID which you are going to onboard"
  type        = string
  default     = null
}

variable "role_id" {
  description = "The Role ID that will be created"
  type        = string
  default     = "orca_security_side_scanner_role_tf"
}
variable "scanner_project_number" {
  description = "Provide the Project Number of the scanner project."
  type        = string
  default     = null
}
variable "service_account_name" {
  description = "The name of the Service Account that will be created"
  type        = string
  default     = "orca-security-side-scanner-tf"
}
variable "enable_kms" {
  description = "Add KMS permissions to enable Orca to scan encrypted drives"
  type        = bool
  default     = true
}


################################################################################################################################################
#                                                 DSPM                                                                                         #
################################################################################################################################################

variable "enable_dspm" {
  description = "Add DSPM permissions"
  type        = bool
  default     = true
}

variable "dspm_target_role_id" {
  description = "The DSPM target Role ID that will be created"
  type        = string
  default     = "orca_security_dspm_scanner_role_tf"
}

variable "dspm_org_target_role_id" {
  description = "The Org-level DSPM target role ID that will be created"
  type        = string
  default     = "orca_security_dspm_scanner_role_org_tf"
}

variable "dspm_vendor_role_id" {
  description = "The DSPM vendor role ID that will be created"
  type        = string
  default     = "orca_security_dspm_backup_role_tf"
}

variable "dspm_org_vendor_role_id" {
  description = "The Org-level DSPM vendor role ID that will be created"
  type        = string
  default     = "orca_security_dspm_backup_role_org_tf"
}

################################################################################################################################################
#                                                 Organization (connect multiple accounts)                                                     #
################################################################################################################################################

variable "multiple" {
  description = "Connect multiple accounts"
  type        = bool
  default     = false
}

variable "organization_id" {
  description = "The GCP Organization ID (only required if 'multiple' set to true)"
  type        = string
  default     = null
}

variable "folder_id" {
  description = "The GCP folder ID (only required if 'multiple' set to true. If not provided, by default applies to the entire organization)"
  type        = string
  default     = null
}

################################################################################################################################################
#                                              Create Scanner Account (in account configuration)                                               #
################################################################################################################################################

variable "in_account" {
  description = "Run the scanner inside my account (Not SaaS)"
  type        = bool
  default     = false
}

variable "scanner_project_id" {
  description = "The Scanner GCP Project ID (only required if 'in_account' set to true)"
  type        = string
  default     = null
}