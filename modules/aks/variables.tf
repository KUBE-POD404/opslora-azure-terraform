variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "kubernetes_version" {
  type    = string
  default = null
}

variable "system_subnet_id" {
  type = string
}

variable "apps_subnet_id" {
  type = string
}

variable "app_gateway_id" {
  type = string
}

variable "log_analytics_workspace_id" {
  type = string
}

variable "ssh_public_key" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

