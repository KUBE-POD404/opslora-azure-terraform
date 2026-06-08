data "terraform_remote_state" "platform" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.platform_state_resource_group_name
    storage_account_name = var.platform_state_storage_account_name
    container_name       = var.platform_state_container_name
    key                  = "platform/terraform.tfstate"
    use_azuread_auth     = true
  }
}

locals {
  prefix = "opslora"
  env    = "test"
}

module "resource_groups" {
  source   = "../../modules/resource-groups"
  location = var.location
  tags     = var.tags

  resource_groups = [
    "rg-${local.prefix}-${local.env}-network-${var.location_code}",
    "rg-${local.prefix}-${local.env}-aks-${var.location_code}",
    "rg-${local.prefix}-${local.env}-ingress-${var.location_code}",
    "rg-${local.prefix}-${local.env}-data-${var.location_code}",
    "rg-${local.prefix}-${local.env}-security-${var.location_code}",
    "rg-${local.prefix}-${local.env}-monitoring-${var.location_code}",
  ]
}

module "spoke_network" {
  source              = "../../modules/spoke-network"
  name                = "vnet-${local.prefix}-${local.env}-${var.location_code}-001"
  location            = var.location
  resource_group_name = module.resource_groups.names["rg-${local.prefix}-${local.env}-network-${var.location_code}"]
  address_space       = ["10.41.0.0/20"]
  hub_vnet_id         = data.terraform_remote_state.platform.outputs.hub_vnet_id
  hub_vnet_name       = data.terraform_remote_state.platform.outputs.hub_vnet_name
  hub_rg_name         = data.terraform_remote_state.platform.outputs.hub_network_resource_group_name
  tags                = var.tags
}

module "monitoring" {
  source              = "../../modules/log-analytics"
  name                = "law-${local.prefix}-${local.env}-${var.location_code}-001"
  location            = var.location
  resource_group_name = module.resource_groups.names["rg-${local.prefix}-${local.env}-monitoring-${var.location_code}"]
  retention_in_days   = 30
  tags                = var.tags
}

module "app_gateway" {
  source              = "../../modules/app-gateway"
  name                = "agw-${local.prefix}-${local.env}-${var.location_code}-001"
  location            = var.location
  resource_group_name = module.resource_groups.names["rg-${local.prefix}-${local.env}-ingress-${var.location_code}"]
  subnet_id           = module.spoke_network.subnet_ids["snet-ingress"]
  public_ip_name      = "pip-${local.prefix}-${local.env}-agw-${var.location_code}-001"
  tags                = var.tags
}

module "key_vault" {
  source                     = "../../modules/key-vault"
  name                       = "kv-${local.prefix}-${local.env}-${var.location_code}-001"
  location                   = var.location
  resource_group_name        = module.resource_groups.names["rg-${local.prefix}-${local.env}-security-${var.location_code}"]
  tenant_id                  = var.tenant_id
  private_endpoint_subnet_id = module.spoke_network.subnet_ids["snet-private-endpoints"]
  private_dns_zone_id        = data.terraform_remote_state.platform.outputs.private_dns_zone_ids["privatelink.vaultcore.azure.net"]
  private_endpoint_vnet_rg   = module.resource_groups.names["rg-${local.prefix}-${local.env}-network-${var.location_code}"]
  log_analytics_workspace_id = module.monitoring.workspace_id
  tags                       = var.tags
}

module "mysql" {
  source              = "../../modules/mysql-flexible"
  name                = "mysql-${local.prefix}-${local.env}-${var.location_code}-001"
  location            = var.location
  resource_group_name = module.resource_groups.names["rg-${local.prefix}-${local.env}-data-${var.location_code}"]
  delegated_subnet_id = module.spoke_network.subnet_ids["snet-mysql-flexible"]
  private_dns_zone_id = data.terraform_remote_state.platform.outputs.private_dns_zone_ids["private.mysql.database.azure.com"]
  tags                = var.tags
}

module "aks" {
  source                     = "../../modules/aks"
  name                       = "aks-${local.prefix}-${local.env}-${var.location_code}-001"
  location                   = var.location
  resource_group_name        = module.resource_groups.names["rg-${local.prefix}-${local.env}-aks-${var.location_code}"]
  kubernetes_version         = var.kubernetes_version
  system_subnet_id           = module.spoke_network.subnet_ids["snet-aks-system"]
  apps_subnet_id             = module.spoke_network.subnet_ids["snet-aks-apps"]
  app_gateway_id             = module.app_gateway.id
  log_analytics_workspace_id = module.monitoring.workspace_id
  ssh_public_key             = var.ssh_public_key
  tags                       = var.tags
}

