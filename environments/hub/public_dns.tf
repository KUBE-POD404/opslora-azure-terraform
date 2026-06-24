resource "azurerm_dns_zone" "opslora" {
  name                = "opslora.com"
  resource_group_name = module.resource_groups.names["rg-${local.prefix}-${local.scope}-dns-${var.location_code}"]
  tags                = var.tags
}
