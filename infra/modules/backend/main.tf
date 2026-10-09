resource "random_string" "app_suffix" {
  length  = 6
  upper   = false
  numeric = true
  special = false
}

resource "azurerm_service_plan" "this" {
  name                = "${var.name}-plan"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = var.sku_name

  tags = { Name = "${var.name}-plan" }
}

resource "azurerm_linux_web_app" "this" {
  name                = "${replace(var.name, "-", "")}app${random_string.app_suffix.result}"
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.this.id
  https_only          = true

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on                 = true
    health_check_path         = "/api/health"
    ftps_state                = "FtpsOnly"
    application_stack {
      node_version = "20-lts"
    }
  }

  app_settings = {
    WEBSITES_PORT             = tostring(var.app_port)
    PORT                      = tostring(var.app_port)
    DB_HOST                   = var.db_host
    DB_PORT                   = tostring(var.db_port)
    DB_NAME                   = var.db_name
    DB_USER                   = var.db_user
    AZURE_KEY_VAULT_URL       = var.key_vault_url
    DB_PASSWORD_SECRET_NAME   = var.secret_name
    SCM_DO_BUILD_DURING_DEPLOYMENT = "true"
  }

  tags = { Name = "${var.name}-app" }
}

resource "azurerm_role_assignment" "key_vault_secrets_user" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_web_app.this.identity[0].principal_id
}
