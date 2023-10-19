variable "target_project_id" {
  description = "The GCP Project ID"
  type        = string
}

variable "multiple" {
  description = "Connect multiple accounts"
  type        = bool
}

variable "scanner_project_id" {
  description = "The Scanner GCP Project ID"
  type        = string
}

variable "target_account_role" {
  description = "The Role ID that will be created"
  type        = string
}

variable "service_account_name" {
  description = "The name of the Service Account that will be created"
  type        = string
}

variable "enable_dspm" {
  description = "Add DSPM permissions"
  type        = bool
}

variable "dspm_target_role_id" {
  description = "The DSPM target Role ID that will be created"
  type        = string
  default     = "orca_security_dspm_scanner_role_tf"
}
