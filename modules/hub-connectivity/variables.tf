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

variable "onprem_sites" {
  description = "Site-to-site VPN peers represented by Azure Local Network Gateways. Keys should be stable site slugs such as ai-trivandrum."
  type = map(object({
    gateway_address = string
    address_spaces  = list(string)
  }))
  default = {}
}

variable "onprem_shared_keys" {
  description = "IPsec shared keys by onprem_sites key. Provide real values via secure tfvars or GitHub Actions secrets; never commit real keys."
  type        = map(string)
  sensitive   = true
  default     = {}
}
