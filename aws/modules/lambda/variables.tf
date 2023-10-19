variable "source_file" {
  type = string
}

variable "function_name" {
  type = string
}

variable "lambda_role" {
  type = string
}

variable "alias" {
  type = string
}

variable "env_vars" {
  type = map(string)
  default = {}
}