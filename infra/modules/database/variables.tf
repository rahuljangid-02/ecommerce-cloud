variable "name" {
  description = "Name prefix for all resources."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group in which the database and Key Vault are created."
  type        = string
}

variable "location" {
  description = "Azure region for the database resources."
  type        = string
}

variable "subnet_id" {
  description = "Subnet used for the database network placement."
  type        = string
}

variable "admin_username" {
  type = string
}

variable "database_name" {
  type = string
}

variable "sku_name" {
  type = string
}

variable "storage_mb" {
  type = number
}

variable "version" {
  type = string
}

variable "backup_retention_days" {
  type = number
}
