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

variable "tags" {
  type    = map(string)
  default = {}
}

