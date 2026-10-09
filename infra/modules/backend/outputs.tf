output "default_hostname" {
  description = "Default hostname of the backend app."
  value       = azurerm_linux_web_app.this.default_hostname
}

output "app_name" {
  description = "Name of the backend app."
  value       = azurerm_linux_web_app.this.name
}
