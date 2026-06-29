variable "prefix" {
  type        = string
  description = "Resource name prefix."
}

variable "env" {
  type        = string
  description = "Environment name."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "location_code" {
  type        = string
  description = "Short Azure region code."
}

variable "resource_group_name" {
  type        = string
  description = "Monitoring resource group name."
}

variable "aks_cluster_id" {
  type        = string
  description = "AKS managed cluster resource ID."
}

variable "aks_cluster_name" {
  type        = string
  description = "AKS managed cluster name."
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics workspace resource ID."
}

variable "alert_email_receivers" {
  type        = map(string)
  description = "Map of Azure Monitor action group receiver name to email address. Leave empty to create an action group without email receivers."
  default     = {}
}

variable "enabled" {
  type        = bool
  description = "Enable alert rules."
  default     = true
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Common tags."
}
