output "db_host" {
  description = "Azure PostgreSQL Flexible Server hostname."
  value       = azurerm_postgresql_flexible_server.this.fqdn
}

output "db_port" {
  description = "Database port."
  value       = 5432
}

output "db_name" {
  description = "Database name."
  value       = azurerm_postgresql_flexible_server_database.this.name
}

output "db_username" {
  description = "Database administrator username."
  value       = azurerm_postgresql_flexible_server.this.administrator_login
}

output "key_vault_id" {
  description = "Resource ID of the Key Vault that stores the DB password."
  value       = azurerm_key_vault.db.id
}

output "key_vault_url" {
  description = "URL of the Key Vault used to fetch the DB password."
  value       = azurerm_key_vault.db.vault_uri
}

output "db_secret_name" {
  description = "Secret name holding the database password."
  value       = azurerm_key_vault_secret.db_password.name
}
