output "key" {
  description = "Service Account Key (for single use)."
  sensitive   = true
  value       = module.service_accounts.key
}

output "email" {
  description = "Service Account Email."
  value       = module.service_accounts.email
}
