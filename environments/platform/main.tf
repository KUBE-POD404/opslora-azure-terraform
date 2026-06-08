locals {
  prefix = "opslora"
  scope  = "hub"
}

module "resource_groups" {
  source   = "../../modules/resource-groups"
  location = var.location
  tags     = var.tags

  resource_groups = [
    "rg-${local.prefix}-${local.scope}-network-${var.location_code}",
    "rg-${local.prefix}-${local.scope}-security-${var.location_code}",
    "rg-${local.prefix}-${local.scope}-connectivity-${var.location_code}",
    "rg-${local.prefix}-${local.scope}-dns-${var.location_code}",
    "rg-${local.prefix}-${local.scope}-management-${var.location_code}",
    "rg-${local.prefix}-${local.scope}-monitoring-${var.location_code}",
  ]
}

module "hub_network" {
  source              = "../../modules/hub-network"
  name                = "vnet-${local.prefix}-${local.scope}-${var.location_code}-001"
  location            = var.location
  resource_group_name = module.resource_groups.names["rg-${local.prefix}-${local.scope}-network-${var.location_code}"]
  address_space       = ["10.40.0.0/20"]
  tags                = var.tags
}

module "monitoring" {
  source              = "../../modules/log-analytics"
  name                = "law-${local.prefix}-${local.scope}-${var.location_code}-001"
  location            = var.location
  resource_group_name = module.resource_groups.names["rg-${local.prefix}-${local.scope}-monitoring-${var.location_code}"]
  retention_in_days   = 30
  tags                = var.tags
}

module "private_dns" {
  source              = "../../modules/private-dns"
  resource_group_name = module.resource_groups.names["rg-${local.prefix}-${local.scope}-dns-${var.location_code}"]
  hub_vnet_id         = module.hub_network.vnet_id
  tags                = var.tags
}

