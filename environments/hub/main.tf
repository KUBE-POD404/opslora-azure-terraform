locals {
  prefix = "opslora"
  scope  = "hub"
}

module "governance" {
  source                     = "../../modules/subscription-governance"
  subscription_id            = var.subscription_id
  location                   = var.location
  scope_name                 = local.scope
  admin_principal_object_ids = var.admin_principal_object_ids
  enable_policy_assignments  = var.enable_governance_policy_assignments
  tags                       = var.tags
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
  source                       = "../../modules/private-dns"
  resource_group_name          = module.resource_groups.names["rg-${local.prefix}-${local.scope}-dns-${var.location_code}"]
  hub_vnet_id                  = module.hub_network.vnet_id
  onprem_private_dns_zone_name = var.onprem_private_dns_zone_name
  onprem_a_records             = var.onprem_a_records
  tags                         = var.tags
}

module "hub_security" {
  source                       = "../../modules/hub-security"
  location                     = var.location
  location_code                = var.location_code
  resource_group_name          = module.resource_groups.names["rg-${local.prefix}-${local.scope}-security-${var.location_code}"]
  firewall_resource_group_name = module.resource_groups.names["rg-${local.prefix}-${local.scope}-network-${var.location_code}"]
  firewall_subnet_id           = module.hub_network.subnet_ids["AzureFirewallSubnet"]
  tags                         = var.tags
}

module "hub_management" {
  source              = "../../modules/hub-management"
  location            = var.location
  location_code       = var.location_code
  resource_group_name = module.resource_groups.names["rg-${local.prefix}-${local.scope}-management-${var.location_code}"]
  bastion_subnet_id   = module.hub_network.subnet_ids["AzureBastionSubnet"]
  tags                = var.tags
}

module "hub_dns_resolver" {
  source              = "../../modules/hub-dns-resolver"
  location            = var.location
  location_code       = var.location_code
  resource_group_name = module.resource_groups.names["rg-${local.prefix}-${local.scope}-dns-${var.location_code}"]
  vnet_id             = module.hub_network.vnet_id
  inbound_subnet_id   = module.hub_network.subnet_ids["snet-dns-resolver-inbound"]
  outbound_subnet_id  = module.hub_network.subnet_ids["snet-dns-resolver-outbound"]
  tags                = var.tags
}

module "hub_connectivity" {
  source                      = "../../modules/hub-connectivity"
  location                    = var.location
  location_code               = var.location_code
  resource_group_name         = module.resource_groups.names["rg-${local.prefix}-${local.scope}-connectivity-${var.location_code}"]
  gateway_resource_group_name = module.resource_groups.names["rg-${local.prefix}-${local.scope}-network-${var.location_code}"]
  gateway_subnet_id           = module.hub_network.subnet_ids["GatewaySubnet"]
  onprem_sites                = var.onprem_sites
  onprem_shared_keys          = var.onprem_shared_keys
  tags                        = var.tags
}
