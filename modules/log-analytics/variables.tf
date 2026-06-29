variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "retention_in_days" {
  type    = number
  default = 30
}

variable "managed_grafana_enabled" {
  type    = bool
  default = true
}

variable "managed_grafana_admin_principal_object_ids" {
  type        = list(string)
  description = "Microsoft Entra user/group object IDs that should receive Grafana Admin on the managed Grafana instance."
  default     = []
}

variable "managed_grafana_viewer_principal_object_ids" {
  type        = list(string)
  description = "Microsoft Entra user/group object IDs that should receive Grafana Viewer on the managed Grafana instance."
  default     = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
