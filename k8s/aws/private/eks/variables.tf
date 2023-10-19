variable "cluster_name" {
  type        = string
  description = "The EKS cluster name"
}

variable "orca_role_arn" {
  type        = string
  description = "The ARN for Orca's IAM role"
  default     = ""
}

variable "execution_role" {
  type        = string
  description = "Custom execution role (If not provided, a new role will be created.)"
  default     = ""
}

