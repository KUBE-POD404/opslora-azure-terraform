variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "bastion_subnet_id" {
  type = string
}

variable "location_code" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}


variable "enable_bastion" {
  description = "Create Azure Bastion and its public IP. Keep false unless temporary browser/SSH/RDP access is explicitly needed."
  type        = bool
  default     = false
}
