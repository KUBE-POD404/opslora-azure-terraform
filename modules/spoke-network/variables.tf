variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "address_space" {
  type = list(string)
}

variable "subnet_address_prefixes" {
  type = object({
    aks_system        = string
    aks_apps          = string
    mysql_flexible    = string
    private_endpoints = string
    ingress           = string
  })
  description = "CIDR blocks for the standard Opslora spoke subnets."
  default = {
    aks_system        = "10.41.0.0/23"
    aks_apps          = "10.41.4.0/22"
    mysql_flexible    = "10.41.10.0/27"
    private_endpoints = "10.41.8.0/24"
    ingress           = "10.41.9.0/24"
  }
}

variable "hub_vnet_id" {
  type = string
}

variable "spoke_to_hub_peering_name" {
  type        = string
  description = "Name for the spoke-to-hub VNet peering."
}

variable "tags" {
  type    = map(string)
  default = {}
}
