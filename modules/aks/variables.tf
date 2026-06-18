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

variable "sku_tier" {
  type        = string
  description = "AKS SKU tier. Use Standard for production."
  default     = "Free"

  validation {
    condition     = contains(["Free", "Standard", "Premium"], var.sku_tier)
    error_message = "sku_tier must be Free, Standard, or Premium."
  }
}

variable "private_cluster_enabled" {
  type        = bool
  description = "Whether the AKS API server is private."
  default     = false
}

variable "system_node_pool" {
  type = object({
    vm_size   = string
    min_count = number
    max_count = number
  })
  description = "System node pool sizing."
  default = {
    vm_size   = "Standard_D2_v4"
    min_count = 1
    max_count = 3
  }
}

variable "apps_node_pool" {
  type = object({
    vm_size   = string
    min_count = number
    max_count = number
  })
  description = "Application node pool sizing."
  default = {
    vm_size   = "Standard_D2_v4"
    min_count = 1
    max_count = 5
  }
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

variable "pod_cidr" {
  type        = string
  description = "AKS Azure CNI Overlay pod CIDR."
  default     = "100.64.0.0/16"
}

variable "service_cidr" {
  type        = string
  description = "AKS Kubernetes service CIDR."
  default     = "10.241.0.0/16"
}

variable "dns_service_ip" {
  type        = string
  description = "AKS Kubernetes DNS service IP."
  default     = "10.241.0.10"
}

variable "tags" {
  type    = map(string)
  default = {}
}

