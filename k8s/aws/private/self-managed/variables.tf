variable "orca_role_arn" {
  type        = string
  description = "The ARN for Orca's IAM role"
}

variable "execution_role" {
  type        = string
  description = "Custom execution role (If not provided, a new role will be created.)"
  default     = ""
}

variable "lambda_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs with access to the kubernetes cluster API server endpoint for Orca lambda function"
}

variable "lambda_security_group_ids" {
  type        = list(string)
  description = "List of security groups IDs with access to the kubernetes cluster API server endpoint for Orca lambda function"
}