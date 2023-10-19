variable "deployment_type" {
  description = "Deployment type to install (Supported types: saas/inaccount_scanner_account/inaccount_target_account)"
  type        = string

  validation {
    condition     = contains(["saas", "inaccount_scanner_account", "inaccount_target_account"], var.deployment_type)
    error_message = "Invalid input, options: \"saas\", \"inaccount_scanner_account\", \"inaccount_target_account\"."
  }
}

variable "inaccount_scanner_account_id" {
  description = "When the \"deployment_type\" is \"inaccount_target_account\" you must provide the Scanner account ID."
  type        = string
  default     = null
}

variable "vendor_account_id" {
  description = "The vendor account id. This is supplied by Orca."
  type        = string
  default     = "976280145156"
}

variable "role_external_id" {
  description = "Role external ID. Will be supplied from Orca."
  type        = string
}

variable "aws_partition" {
  description = "AWS partition (aws / aws-cn / aws-us-gov)"
  type        = string
  default     = "aws"
  validation {
    condition     = contains(["aws", "aws-cn", "aws-us-gov"], var.aws_partition)
    error_message = "Allowed values for aws_partition are \"aws\", \"aws-cn\", or \"aws-us-gov\"."
  }
}

variable "role_name" {
  description = "Role Name is created with a default name, if you want changed it."
  type        = string
  default     = "OrcaSecurityRole"
}

variable "policy_name" {
  description = "Policy Name is created with a default name, if you want changed it."
  type        = string
  default     = "OrcaSecurityPolicy"
}

variable "secrets_manager_access" {
  description = "Whether to attach SecretsManager policy to Orca's role. Default: true"
  type        = bool
  default     = true
}

variable "enable_dspm" {
  description = "Whether to add RDS scanner policy to Orca's role. Default: true"
  type        = bool
  default     = true
}

variable "deploy_stack_set" {
  description = "Orca Organization-level stack set. This stack set will automatically deploy Orca permissions on OU or all Organization's accounts (Deploy in your organization MANAGEMENT ACCOUNT)."
  type        = bool
  default     = false
}

variable "organizational_unit_ids" {
  description = "When you choose to deploy a stack set, you can choose organizational unit ids to which it will apply (If not provided, the default is to apply to the entire organization)."
  type        = list(string)
  default     = null
}

variable "bucket_name" {
  description = "S3 bucket for terraform files"
  type        = string
  default     = "orca-onboarding-files-production-us-east-1"
}

variable "backend_url" {
  description = "Orca's backend URL"
  type        = string
  default     = "https://api.orcasecurity.io"
}

variable "create_rds_service_linked_role" {
  description = "Set 'false' if AWSServiceRoleForRDS IAM role already exists in your AWS account. If set to 'true' and the role exists then terraform will fail with 400:InvalidInput. Default: true"
  type        = bool
  default     = true
}

variable "assume_role_policy_template" {
  description = "The vendor account id. This is supplied by Orca."
  type        = string
  default     = null
}
