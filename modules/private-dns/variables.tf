variable "resource_group_name" {
  type = string
}

variable "hub_vnet_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

