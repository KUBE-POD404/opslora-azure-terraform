data "terraform_remote_state" "hub" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.hub_state_resource_group_name
    storage_account_name = var.hub_state_storage_account_name
    container_name       = var.hub_state_container_name
    key                  = "platform/terraform.tfstate"
    use_azuread_auth     = true
  }
}

locals {
  prefix                      = "opslora"
  env                         = "test"
  hub_scope                   = "hub"
  ingress_resource_group_name = "rg-${local.prefix}-${local.env}-ingress-${var.location_code}"
  private_dns_zone_names = [
    "private.mysql.database.azure.com",
    "privatelink.blob.core.windows.net",
    "privatelink.vaultcore.azure.net",
  ]
}

module "governance" {
  source                     = "../../modules/subscription-governance"
  subscription_id            = var.subscription_id
  location                   = var.location
  scope_name                 = local.env
  admin_principal_object_ids = var.admin_principal_object_ids
  enable_policy_assignments  = var.enable_governance_policy_assignments
  tags                       = var.tags
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
  hub_vnet_id         = data.terraform_remote_state.hub.outputs.hub_vnet_id
  tags                = var.tags
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  provider = azurerm.hub

  name                         = "peer-hub-to-test-cin-001"
  resource_group_name          = data.terraform_remote_state.hub.outputs.hub_network_resource_group_name
  virtual_network_name         = data.terraform_remote_state.hub.outputs.hub_vnet_name
  remote_virtual_network_id    = module.spoke_network.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
}

resource "azurerm_private_dns_zone_virtual_network_link" "test" {
  provider = azurerm.hub

  for_each = toset(local.private_dns_zone_names)

  name                  = "pdnslink-${local.prefix}-${local.env}-${var.location_code}-001-${replace(each.key, ".", "-")}"
  resource_group_name   = "rg-${local.prefix}-${local.hub_scope}-dns-${var.location_code}"
  private_dns_zone_name = each.key
  virtual_network_id    = module.spoke_network.vnet_id
  registration_enabled  = false
  tags                  = var.tags
}

module "monitoring" {
  source                  = "../../modules/log-analytics"
  name                    = "law-${local.prefix}-${local.env}-${var.location_code}-001"
  location                = var.location
  resource_group_name     = module.resource_groups.names["rg-${local.prefix}-${local.env}-monitoring-${var.location_code}"]
  retention_in_days       = 30
  managed_grafana_enabled = false
  tags                    = var.tags
}

module "app_gateway" {
  source              = "../../modules/app-gateway"
  name                = "agw-${local.prefix}-${local.env}-${var.location_code}-001"
  location            = var.location
  resource_group_name = module.resource_groups.names[local.ingress_resource_group_name]
  subnet_id           = module.spoke_network.subnet_ids["snet-ingress"]
  public_ip_name      = "pip-${local.prefix}-${local.env}-agw-${var.location_code}-001"
  waf_mode            = "Detection"
  tags                = var.tags
}

module "key_vault" {
  source                     = "../../modules/key-vault"
  name                       = "kv-${local.prefix}-${local.env}-${var.location_code}-001"
  location                   = var.location
  resource_group_name        = module.resource_groups.names["rg-${local.prefix}-${local.env}-security-${var.location_code}"]
  tenant_id                  = var.tenant_id
  private_endpoint_subnet_id = module.spoke_network.subnet_ids["snet-private-endpoints"]
  private_dns_zone_id        = data.terraform_remote_state.hub.outputs.private_dns_zone_ids["privatelink.vaultcore.azure.net"]
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
  private_dns_zone_id = data.terraform_remote_state.hub.outputs.private_dns_zone_ids["private.mysql.database.azure.com"]
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

resource "azurerm_role_assignment" "aks_key_vault_secrets_provider" {
  scope                = module.key_vault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.aks.key_vault_secrets_provider_object_id
}

resource "azurerm_role_assignment" "agic_ingress_rg_reader" {
  scope                = "/subscriptions/${var.subscription_id}/resourceGroups/${local.ingress_resource_group_name}"
  role_definition_name = "Reader"
  principal_id         = module.aks.agic_object_id
}

resource "azurerm_role_assignment" "agic_app_gateway_contributor" {
  scope                = module.app_gateway.id
  role_definition_name = "Contributor"
  principal_id         = module.aks.agic_object_id
}

resource "azurerm_role_assignment" "agic_ingress_subnet_network_contributor" {
  scope                = module.spoke_network.subnet_ids["snet-ingress"]
  role_definition_name = "Network Contributor"
  principal_id         = module.aks.agic_object_id
}
