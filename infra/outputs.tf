output "resource_group_name" {
  description = "Azure resource group containing the deployment."
  value       = azurerm_resource_group.main.name
}

output "frontend_url" {
  description = "Public HTTPS URL of the frontend."
  value       = "https://${module.frontend.cdn_endpoint_hostname}"
}

output "backend_url" {
  description = "Public HTTPS URL of the backend app."
  value       = "https://${module.backend.default_hostname}"
}

output "database_host" {
  description = "Azure PostgreSQL Flexible Server hostname."
  value       = module.database.db_host
}

output "database_name" {
  description = "Database name."
  value       = module.database.db_name
}

output "key_vault_url" {
  description = "Key Vault URL that stores the database password."
  value       = module.database.key_vault_url
}

output "db_secret_name" {
  description = "Secret name used by the backend to fetch the database password."
  value       = module.database.db_secret_name
}
