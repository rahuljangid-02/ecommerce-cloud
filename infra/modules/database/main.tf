resource "random_string" "vault_suffix" {
  length  = 4
  upper   = false
  numeric = true
  special = false
}

resource "random_password" "db" {
  length           = 24
  special          = true
  override_special = "!@#$%^&*()-_=+[]{}<>?"
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "db" {
  name                = substr("${lower(replace(var.name, "-", ""))}kv${random_string.vault_suffix.result}", 0, 24)
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  purge_protection_enabled = false
  soft_delete_retention_days = 7

  tags = { Name = "${var.name}-kv" }
}

resource "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  value        = random_password.db.result
  key_vault_id = azurerm_key_vault.db.id
}

resource "azurerm_private_dns_zone" "postgres" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = var.resource_group_name

  tags = { Name = "${var.name}-postgres-dns" }
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name                  = "${var.name}-postgres-vnet-link"
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  virtual_network_id    = var.vnet_id
  resource_group_name   = var.resource_group_name
}

resource "azurerm_postgresql_flexible_server" "this" {
  name                   = "${var.name}-postgres"
  location               = var.location
  resource_group_name    = var.resource_group_name
  version                = var.version
  sku_name               = var.sku_name
  storage_mb             = var.storage_mb
  administrator_login    = var.admin_username
  administrator_password = random_password.db.result
  zone                   = "1"

  public_network_access_enabled = false
  backup_retention_days         = var.backup_retention_days
  tags                          = { Name = "${var.name}-postgres" }
}

resource "azurerm_postgresql_flexible_server_database" "this" {
  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.this.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

resource "azurerm_private_endpoint" "postgres" {
  name                = "${var.name}-postgres-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.name}-postgres-psc"
    private_connection_resource_id = azurerm_postgresql_flexible_server.this.id
    is_manual_connection           = false
    subresource_names              = ["postgresqlServer"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.postgres.id]
  }
}
