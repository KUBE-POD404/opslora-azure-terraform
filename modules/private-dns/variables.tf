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

variable "onprem_private_dns_zone_name" {
  description = "Private DNS zone used for stable on-prem workload names reachable from Azure over VPN."
  type        = string
  default     = "onprem.opslora.internal"
}

variable "onprem_a_records" {
  description = "A records for stable on-prem endpoints, keyed by host label, for example ai-gateway => 172.16.10.10."
  type        = map(string)
  default     = {}
}

