variable "name" {
  type        = string
  description = "Globally unique Azure Container Registry name. Must be 5-50 lowercase alphanumeric characters."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name for the registry."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "sku" {
  type        = string
  description = "ACR SKU. Premium is required for private endpoints, zone redundancy, and trust policy."
  default     = "Standard"
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Whether public network access is enabled for ACR. Keep true until private endpoint/DNS is wired."
  default     = true
}

variable "zone_redundancy_enabled" {
  type        = bool
  description = "Enable zone redundancy. Requires Premium SKU in supported regions."
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Resource tags."
  default     = {}
}
