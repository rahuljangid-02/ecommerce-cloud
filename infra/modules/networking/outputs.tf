output "vnet_id" {
  description = "ID of the Azure virtual network."
  value       = azurerm_virtual_network.this.id
}

output "app_subnet_id" {
  description = "ID of the application subnet."
  value       = azurerm_subnet.app.id
}

output "db_subnet_id" {
  description = "ID of the database subnet."
  value       = azurerm_subnet.db.id
}

output "app_nsg_id" {
  description = "Security group for the app tier."
  value       = azurerm_network_security_group.app.id
}
