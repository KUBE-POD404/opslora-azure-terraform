resource "azurerm_kubernetes_cluster" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.name
  kubernetes_version  = var.kubernetes_version
  sku_tier            = "Free"
  tags                = var.tags

  default_node_pool {
    name                         = "system"
    vm_size                      = "Standard_D2s_v5"
    vnet_subnet_id               = var.system_subnet_id
    auto_scaling_enabled         = true
    min_count                    = 1
    max_count                    = 3
    orchestrator_version         = var.kubernetes_version
    only_critical_addons_enabled = true
  }

  identity {
    type = "SystemAssigned"
  }

  linux_profile {
    admin_username = "azureuser"

    ssh_key {
      key_data = var.ssh_public_key
    }
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = "azure"
    pod_cidr            = "100.64.0.0/16"
    service_cidr        = "10.241.0.0/16"
    dns_service_ip      = "10.241.0.10"
    outbound_type       = "loadBalancer"
  }

  ingress_application_gateway {
    gateway_id = var.app_gateway_id
  }

  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  monitor_metrics {}

  workload_identity_enabled = true
  oidc_issuer_enabled       = true
}

resource "azurerm_kubernetes_cluster_node_pool" "apps" {
  name                  = "apps"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = "Standard_D2s_v5"
  vnet_subnet_id        = var.apps_subnet_id
  auto_scaling_enabled  = true
  min_count             = 1
  max_count             = 5
  mode                  = "User"
  orchestrator_version  = var.kubernetes_version
  tags                  = var.tags
}
