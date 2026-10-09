variable "name" {
  description = "Name prefix for all resources."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group in which the App Service is created."
  type        = string
}

variable "location" {
  description = "Azure region for the backend service."
  type        = string
}

variable "app_subnet_id" {
  description = "Optional subnet ID for backend placement."
  type        = string
  default     = ""
}

variable "app_port" {
  description = "Port the backend app listens on."
  type        = number
}

variable "sku_name" {
  description = "SKU for the Azure App Service plan."
  type        = string
  default     = "B1"
}

variable "db_host" {
  type = string
}

variable "db_port" {
  type = number
}

variable "db_name" {
  type = string
}

variable "db_user" {
  type = string
}

variable "key_vault_id" {
  description = "Key Vault resource ID used to read the database password."
  type        = string
}

variable "key_vault_url" {
  description = "Key Vault URL used by the app to fetch the DB password."
  type        = string
}

variable "secret_name" {
  description = "Name of the secret that contains the database password."
  type        = string
}
