locals {
  orca_assume_role_policy = var.assume_role_policy_template != null ? var.assume_role_policy_template  : templatefile("${path.module}/templates/assume_role_template.tftpl",  {vendor_account_id = var.vendor_account_id, role_external_id = var.role_external_id, aws_partition = var.aws_partition})
}