variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "delegated_subnet_id" {
  type = string
}

variable "private_dns_zone_id" {
  type = string
}

variable "administrator_login" {
  type        = string
  description = "Temporary bootstrap admin login. Move secret handling to Key Vault before production."
  default     = "opsloraadmin"
}

variable "administrator_password" {
  type        = string
  description = "Temporary bootstrap admin password. Do not commit real values."
  sensitive   = true
  default     = null
}

variable "sku_name" {
  type        = string
  description = "MySQL Flexible Server SKU."
  default     = "B_Standard_B1ms"
}

variable "mysql_version" {
  type        = string
  description = "MySQL Flexible Server engine version."
  default     = "8.0.21"
}

variable "backup_retention_days" {
  type        = number
  description = "Backup retention in days."
  default     = 7
}

variable "geo_redundant_backup_enabled" {
  type        = bool
  description = "Enable geo-redundant backups where Azure supports it."
  default     = false
}

variable "zone" {
  type        = string
  description = "Primary availability zone."
  default     = "1"
}

variable "high_availability" {
  type = object({
    enabled                   = bool
    mode                      = string
    standby_availability_zone = optional(string)
  })
  description = "Optional high availability settings for production."
  default = {
    enabled = false
    mode    = "ZoneRedundant"
  }
}

variable "tags" {
  type    = map(string)
  default = {}
}

