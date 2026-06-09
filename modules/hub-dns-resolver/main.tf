resource "azurerm_private_dns_resolver" "this" {
  name                = "dnspr-opslora-hub-${var.location_code}-001"
  resource_group_name = var.resource_group_name
  location            = var.location
  virtual_network_id  = var.vnet_id
  tags                = var.tags
}

resource "azurerm_private_dns_resolver_inbound_endpoint" "this" {
  name                    = "dnspr-in-opslora-hub-${var.location_code}-001"
  private_dns_resolver_id = azurerm_private_dns_resolver.this.id
  location                = var.location
  tags                    = var.tags

  ip_configurations {
    private_ip_allocation_method = "Dynamic"
    subnet_id                    = var.inbound_subnet_id
  }
}

resource "azurerm_private_dns_resolver_outbound_endpoint" "this" {
  name                    = "dnspr-out-opslora-hub-${var.location_code}-001"
  private_dns_resolver_id = azurerm_private_dns_resolver.this.id
  location                = var.location
  subnet_id               = var.outbound_subnet_id
  tags                    = var.tags
}
