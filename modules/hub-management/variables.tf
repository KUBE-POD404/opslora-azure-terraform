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
