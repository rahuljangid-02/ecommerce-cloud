resource "random_string" "storage_suffix" {
  length  = 6
  upper   = false
  numeric = true
  special = false
}

resource "azurerm_storage_account" "site" {
  name                     = substr("${lower(replace(var.name, "-", ""))}${random_string.storage_suffix.result}", 0, 24)
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  https_traffic_only_enabled = true

  static_website {
    index_document = "index.html"
    error_404_document = "404.html"
  }

  tags = { Name = "${var.name}-frontend" }
}

resource "azurerm_cdn_profile" "this" {
  name                = "${var.name}-cdn"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.cdn_sku

  tags = { Name = "${var.name}-cdn" }
}

resource "azurerm_cdn_endpoint" "this" {
  name                = "${replace(var.name, "-", "")}cdn${random_string.storage_suffix.result}"
  profile_name        = azurerm_cdn_profile.this.name
  location            = var.location
  resource_group_name = var.resource_group_name
  origin {
    name      = "frontend-origin"
    host_name = azurerm_storage_account.site.primary_web_host
    http_port = 80
    https_port = 443
  }

  querystring_caching_behaviour = "IgnoreQueryString"
  is_http_allowed               = true
  is_https_allowed              = true
  content_types_to_compress     = ["text/html", "text/css", "application/javascript", "application/json"]
  compression_enabled           = true
}
