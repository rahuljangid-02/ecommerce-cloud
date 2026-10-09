variable "location" {
  description = "Azure region to deploy into."
  type        = string
  default     = "eastus"
}

variable "project_name" {
  description = "Short name used as a prefix for every resource."
  type        = string
  default     = "ecommerce"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,15}$", var.project_name))
    error_message = "project_name must be 2-16 characters: lowercase letters, digits and hyphens, starting with a letter."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)."
  type        = string
  default     = "dev"

  validation {
    condition     = can(regex("^[a-z0-9]{2,8}$", var.environment))
    error_message = "environment must be 2-8 lowercase letters or digits."
  }
}

# ---------------------------------------------------------------- Networking

variable "vnet_cidr" {
  description = "CIDR block for the Azure virtual network."
  type        = string
  default     = "10.0.0.0/16"
}

variable "app_subnet_cidr" {
  description = "CIDR block for the application subnet."
  type        = string
  default     = "10.0.0.0/24"
}

variable "db_subnet_cidr" {
  description = "CIDR block for the database subnet."
  type        = string
  default     = "10.0.1.0/24"
}

# ------------------------------------------------------------------- Backend

variable "backend_port" {
  description = "Port the backend app listens on."
  type        = number
  default     = 8080
}

variable "backend_sku_name" {
  description = "App Service plan SKU for the backend."
  type        = string
  default     = "B1"
}

# ------------------------------------------------------------------ Database

variable "db_sku_name" {
  description = "Azure PostgreSQL Flexible Server SKU."
  type        = string
  default     = "B_Standard_B1ms"
}

variable "db_storage_mb" {
  description = "Storage in MB for the PostgreSQL Flexible Server."
  type        = number
  default     = 32768
}

variable "db_version" {
  description = "PostgreSQL major version."
  type        = string
  default     = "16"
}

variable "db_name" {
  description = "Name of the initial PostgreSQL database."
  type        = string
  default     = "ecommerce"
}

variable "db_username" {
  description = "Master username for the database. The password is generated and stored in Azure Key Vault."
  type        = string
  default     = "appadmin"
}

variable "db_backup_retention_days" {
  description = "Days to keep automated backups."
  type        = number
  default     = 7
}

# ------------------------------------------------------------------ Frontend

variable "cdn_sku" {
  description = "Azure CDN profile SKU."
  type        = string
  default     = "Standard_Microsoft"
}
