resource "azurerm_log_analytics_workspace" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.retention_in_days
  tags                = var.tags
}

resource "azurerm_monitor_workspace" "this" {
  name                = replace(var.name, "law-", "amw-")
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

locals {
  managed_grafana_name = substr(replace(var.name, "law-", "amg-"), 0, 23)
}

resource "azurerm_dashboard_grafana" "this" {
  count = var.managed_grafana_enabled ? 1 : 0

  name                              = local.managed_grafana_name
  location                          = var.location
  resource_group_name               = var.resource_group_name
  api_key_enabled                   = false
  deterministic_outbound_ip_enabled = false
  public_network_access_enabled     = true
  sku                               = "Standard"
  grafana_major_version             = "12"
  tags                              = var.tags

  azure_monitor_workspace_integrations {
    resource_id = azurerm_monitor_workspace.this.id
  }
}
