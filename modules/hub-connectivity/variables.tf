variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "gateway_resource_group_name" {
  type = string
}

variable "gateway_subnet_id" {
  type = string
}

variable "location_code" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
