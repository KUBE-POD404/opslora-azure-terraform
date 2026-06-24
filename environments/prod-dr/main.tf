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
  env                         = "prod-dr"
  hub_scope                   = "hub"
  ingress_resource_group_name = "rg-${local.prefix}-${local.env}-ingress-${var.location_code}"
  resource_group_names = {
    network    = "rg-${local.prefix}-${local.env}-network-${var.location_code}"
    aks        = "rg-${local.prefix}-${local.env}-aks-${var.location_code}"
    ingress    = local.ingress_resource_group_name
    data       = "rg-${local.prefix}-${local.env}-data-${var.location_code}"
    security   = "rg-${local.prefix}-${local.env}-security-${var.location_code}"
    monitoring = "rg-${local.prefix}-${local.env}-monitoring-${var.location_code}"
  }
  private_dns_zone_names = [
    "private.mysql.database.azure.com",
    "privatelink.blob.core.windows.net",
    "privatelink.vaultcore.azure.net",
  ]
  rbac_assignments = var.enable_rbac_assignments ? {
    prod_dr_network_admins = {
      scope_id             = module.resource_groups.ids[local.resource_group_names.network]
      role_definition_name = "Network Contributor"
      principal_id         = var.rbac_group_object_ids["opslora-network-admins"]
    }
    prod_dr_security_admins = {
      scope_id             = module.resource_groups.ids[local.resource_group_names.security]
      role_definition_name = "Key Vault Administrator"
      principal_id         = var.rbac_group_object_ids["opslora-security-admins"]
    }
    prod_dr_data_admins = {
      scope_id             = module.resource_groups.ids[local.resource_group_names.data]
      role_definition_name = "Contributor"
      principal_id         = var.rbac_group_object_ids["opslora-data-admins"]
    }
    prod_dr_aks_admins = {
      scope_id             = module.aks.id
      role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
      principal_id         = var.rbac_group_object_ids["opslora-aks-admins-prod"]
    }
    prod_dr_observability_admins = {
      scope_id             = module.resource_groups.ids[local.resource_group_names.monitoring]
      role_definition_name = "Monitoring Contributor"
      principal_id         = var.rbac_group_object_ids["opslora-observability-admins"]
    }
    prod_dr_breakglass_admins = {
      scope_id             = "/subscriptions/${var.subscription_id}"
      role_definition_name = "Owner"
      principal_id         = var.rbac_group_object_ids["opslora-breakglass-admins"]
    }
  } : {}
}

module "governance" {
  source                          = "../../modules/subscription-governance"
  subscription_id                 = var.subscription_id
  location                        = var.location
  scope_name                      = local.env
  enable_policy_assignments       = var.enable_governance_policy_assignments
  policy_effect                   = "Deny"
  key_vault_public_network_effect = "Deny"
  aks_workload_identity_effect    = "Audit"
  tags                            = var.tags
}

module "resource_groups" {
  source   = "../../modules/resource-groups"
  location = var.location
  tags     = var.tags

  resource_groups = values(local.resource_group_names)
}

module "spoke_network" {
  source              = "../../modules/spoke-network"
  name                = "vnet-${local.prefix}-${local.env}-${var.location_code}-001"
  location            = var.location
  resource_group_name = module.resource_groups.names[local.resource_group_names.network]
  address_space       = ["10.43.0.0/20"]
  subnet_address_prefixes = {
    aks_system        = "10.43.0.0/23"
    aks_apps          = "10.43.4.0/22"
    private_endpoints = "10.43.8.0/24"
    ingress           = "10.43.9.0/24"
    mysql_flexible    = "10.43.10.0/27"
  }
  hub_vnet_id               = data.terraform_remote_state.hub.outputs.hub_vnet_id
  spoke_to_hub_peering_name = "peer-${local.env}-to-hub-${var.location_code}-001"
  tags                      = var.tags
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  provider = azurerm.hub

  name                         = "peer-hub-to-${local.env}-${var.location_code}-001"
  resource_group_name          = data.terraform_remote_state.hub.outputs.hub_network_resource_group_name
  virtual_network_name         = data.terraform_remote_state.hub.outputs.hub_vnet_name
  remote_virtual_network_id    = module.spoke_network.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
}

resource "azurerm_private_dns_zone_virtual_network_link" "prod_dr" {
  provider = azurerm.hub

  for_each = toset(local.private_dns_zone_names)

  name                  = "pdnslink-${local.prefix}-${local.env}-${var.location_code}-001-${replace(each.key, ".", "-")}"
  resource_group_name   = "rg-${local.prefix}-${local.hub_scope}-dns-${var.hub_location_code}"
  private_dns_zone_name = each.key
  virtual_network_id    = module.spoke_network.vnet_id
  registration_enabled  = false
  tags                  = var.tags
}

module "monitoring" {
  source                  = "../../modules/log-analytics"
  name                    = "law-${local.prefix}-${local.env}-${var.location_code}-001"
  location                = var.location
  resource_group_name     = module.resource_groups.names[local.resource_group_names.monitoring]
  retention_in_days       = 90
  managed_grafana_enabled = false
  tags                    = var.tags
}

module "app_gateway" {
  source              = "../../modules/app-gateway"
  name                = "agw-${local.prefix}-${local.env}-${var.location_code}-001"
  location            = var.location
  resource_group_name = module.resource_groups.names[local.resource_group_names.ingress]
  subnet_id           = module.spoke_network.subnet_ids["snet-ingress"]
  public_ip_name      = "pip-${local.prefix}-${local.env}-agw-${var.location_code}-001"
  waf_mode            = "Prevention"
  tags                = var.tags
}

module "key_vault" {
  source                     = "../../modules/key-vault"
  name                       = "kv-${local.prefix}-pdr-${var.location_code}-001"
  location                   = var.location
  resource_group_name        = module.resource_groups.names[local.resource_group_names.security]
  tenant_id                  = var.tenant_id
  private_endpoint_subnet_id = module.spoke_network.subnet_ids["snet-private-endpoints"]
  private_dns_zone_id        = data.terraform_remote_state.hub.outputs.private_dns_zone_ids["privatelink.vaultcore.azure.net"]
  private_endpoint_vnet_rg   = module.resource_groups.names[local.resource_group_names.network]
  log_analytics_workspace_id = module.monitoring.workspace_id
  tags                       = var.tags
}

module "mysql" {
  source                       = "../../modules/mysql-flexible"
  name                         = "mysql-${local.prefix}-${local.env}-${var.location_code}-001"
  location                     = var.location
  resource_group_name          = module.resource_groups.names[local.resource_group_names.data]
  delegated_subnet_id          = module.spoke_network.subnet_ids["snet-mysql-flexible"]
  private_dns_zone_id          = data.terraform_remote_state.hub.outputs.private_dns_zone_ids["private.mysql.database.azure.com"]
  sku_name                     = "GP_Standard_D2ds_v4"
  backup_retention_days        = 35
  geo_redundant_backup_enabled = true
  tags                         = var.tags
}

module "aks" {
  source                     = "../../modules/aks"
  name                       = "aks-${local.prefix}-${local.env}-${var.location_code}-001"
  location                   = var.location
  resource_group_name        = module.resource_groups.names[local.resource_group_names.aks]
  kubernetes_version         = var.kubernetes_version
  sku_tier                   = "Standard"
  private_cluster_enabled    = var.prod_dr_private_cluster_enabled
  system_subnet_id           = module.spoke_network.subnet_ids["snet-aks-system"]
  apps_subnet_id             = module.spoke_network.subnet_ids["snet-aks-apps"]
  app_gateway_id             = module.app_gateway.id
  log_analytics_workspace_id = module.monitoring.workspace_id
  ssh_public_key             = var.ssh_public_key
  pod_cidr                   = "100.66.0.0/16"
  service_cidr               = "10.243.0.0/16"
  dns_service_ip             = "10.243.0.10"
  system_node_pool = {
    vm_size   = "Standard_D2s_v3"
    min_count = 1
    max_count = 3
  }
  apps_node_pool = {
    vm_size   = "Standard_D4s_v3"
    min_count = 1
    max_count = 5
  }
  tags = var.tags
}

module "rbac" {
  source      = "../../modules/resource-group-rbac"
  assignments = local.rbac_assignments
}

resource "azurerm_role_assignment" "aks_key_vault_secrets_provider" {
  scope                = module.key_vault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.aks.key_vault_secrets_provider_object_id
}

resource "azurerm_role_assignment" "agic_ingress_rg_reader" {
  scope                = module.resource_groups.ids[local.resource_group_names.ingress]
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
