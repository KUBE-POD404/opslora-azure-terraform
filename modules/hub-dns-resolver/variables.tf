variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "vnet_id" {
  type = string
}

variable "inbound_subnet_id" {
  type = string
}

variable "outbound_subnet_id" {
  type = string
}

variable "location_code" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
