locals {
  zones = toset([
    "private.mysql.database.azure.com",
    "privatelink.vaultcore.azure.net",
    "privatelink.blob.core.windows.net",
  ])
}

resource "azurerm_private_dns_zone" "this" {
  for_each            = local.zones
  name                = each.value
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "hub" {
  for_each              = azurerm_private_dns_zone.this
  name                  = "pdnslink-opslora-hub-cin-001-${replace(each.key, ".", "-")}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = each.value.name
  virtual_network_id    = var.hub_vnet_id
  registration_enabled  = false
  tags                  = var.tags
}

resource "azurerm_private_dns_zone" "onprem" {
  count               = length(var.onprem_a_records) > 0 ? 1 : 0
  name                = var.onprem_private_dns_zone_name
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "onprem_hub" {
  count                 = length(var.onprem_a_records) > 0 ? 1 : 0
  name                  = "pdnslink-opslora-hub-cin-001-${replace(var.onprem_private_dns_zone_name, ".", "-")}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.onprem[0].name
  virtual_network_id    = var.hub_vnet_id
  registration_enabled  = false
  tags                  = var.tags
}

resource "azurerm_private_dns_a_record" "onprem" {
  for_each            = var.onprem_a_records
  name                = each.key
  zone_name           = azurerm_private_dns_zone.onprem[0].name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [each.value]
  tags                = var.tags
}

