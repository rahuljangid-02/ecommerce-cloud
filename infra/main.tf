locals {
  name = "${var.project_name}-${var.environment}"
}

resource "azurerm_resource_group" "main" {
  name     = "${local.name}-rg"
  location = var.location
}

# ------------------------------------------------------------------ Networking
module "networking" {
  source = "./modules/networking"

  name                = local.name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  vnet_cidr           = var.vnet_cidr
  app_subnet_cidr     = var.app_subnet_cidr
  db_subnet_cidr      = var.db_subnet_cidr
}

# ------------------------------------------------------------------- Database
module "database" {
  source = "./modules/database"

  name                  = local.name
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  subnet_id             = module.networking.db_subnet_id
  admin_username        = var.db_username
  database_name         = var.db_name
  sku_name              = var.db_sku_name
  storage_mb            = var.db_storage_mb
  version               = var.db_version
  backup_retention_days = var.db_backup_retention_days
}

# ------------------------------------------------------------------ Backend
module "backend" {
  source = "./modules/backend"

  name                = local.name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  app_subnet_id       = module.networking.app_subnet_id
  app_port            = var.backend_port
  sku_name            = var.backend_sku_name

  db_host       = module.database.db_host
  db_port       = module.database.db_port
  db_name       = module.database.db_name
  db_user       = module.database.db_username
  key_vault_id  = module.database.key_vault_id
  key_vault_url = module.database.key_vault_url
  secret_name   = module.database.db_secret_name
}

# ------------------------------------------------------------------ Frontend
module "frontend" {
  source = "./modules/frontend"

  name                = local.name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  cdn_sku             = var.cdn_sku
  backend_hostname    = module.backend.default_hostname
}
