variable "name" {
  description = "Name prefix for all resources."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group in which all networking resources are created."
  type        = string
}

variable "location" {
  description = "Azure region for networking resources."
  type        = string
}

variable "vnet_cidr" {
  description = "CIDR block for the Azure virtual network."
  type        = string
}

variable "app_subnet_cidr" {
  description = "CIDR block for the application subnet."
  type        = string
}

variable "db_subnet_cidr" {
  description = "CIDR block for the database subnet."
  type        = string
}

variable "app_port" {
  description = "Port the backend app listens on."
  type        = number
  default     = 8080
}
