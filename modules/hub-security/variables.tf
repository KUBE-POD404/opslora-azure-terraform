variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "firewall_resource_group_name" {
  type = string
}

variable "firewall_subnet_id" {
  type = string
}

variable "location_code" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
