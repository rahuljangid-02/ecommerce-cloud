output "storage_account_name" {
  description = "Storage account used for the frontend content."
  value       = azurerm_storage_account.site.name
}

output "cdn_endpoint_hostname" {
  description = "CDN hostname for the frontend."
  value       = azurerm_cdn_endpoint.this.host_name
}
