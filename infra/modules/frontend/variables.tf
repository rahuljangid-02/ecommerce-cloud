variable "name" {
  description = "Name prefix for all resources."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group in which the CDN and storage account are created."
  type        = string
}

variable "location" {
  description = "Azure region for the frontend resources."
  type        = string
}

variable "cdn_sku" {
  description = "Azure CDN profile SKU."
  type        = string
  default     = "Standard_Microsoft"
}

variable "backend_hostname" {
  description = "Public hostname of the backend app if you want to proxy API traffic."
  type        = string
  default     = ""
}
