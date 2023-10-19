output "orca_role_arn" {
  description = "Role ARN to be used to onboard"
  value       = aws_iam_role.role.arn
}

output "orca_side_scanner_role_arn" {
  description = "Side Scanner Role ARN to be used to onboard"
  value       = var.deployment_type == "inaccount_target_account" ? aws_iam_role.side_scanner[0].arn : "N/A"
}

output "customer_account_id" {
  description = "This is the account id to be used for onboarding the account"
  value       = data.aws_caller_identity.current.account_id
}
