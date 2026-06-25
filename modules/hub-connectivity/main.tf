resource "azurerm_public_ip" "vpn_gateway" {
  count = var.enable_vpn_gateway ? 1 : 0

  name                = "pip-opslora-vpngw-${var.location_code}-001"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
  tags                = var.tags
}

resource "azurerm_virtual_network_gateway" "this" {
  count = var.enable_vpn_gateway ? 1 : 0

  name                = "vpngw-opslora-hub-${var.location_code}-001"
  location            = var.location
  resource_group_name = var.gateway_resource_group_name
  type                = "Vpn"
  vpn_type            = "RouteBased"
  active_active       = false
  bgp_enabled         = false
  sku                 = "VpnGw1AZ"
  generation          = "Generation1"
  tags                = var.tags

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vpn_gateway[0].id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.gateway_subnet_id
  }
}

resource "azurerm_local_network_gateway" "onprem" {
  for_each = var.enable_vpn_gateway ? var.onprem_sites : {}

  name                = "lgw-opslora-${each.key}-${var.location_code}-001"
  location            = var.location
  resource_group_name = var.resource_group_name
  gateway_address     = each.value.gateway_address
  address_space       = each.value.address_spaces
  tags                = var.tags
}

resource "azurerm_virtual_network_gateway_connection" "onprem" {
  for_each = var.enable_vpn_gateway ? var.onprem_sites : {}

  name                       = "cn-opslora-hub-${each.key}-${var.location_code}-001"
  location                   = var.location
  resource_group_name        = var.gateway_resource_group_name
  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.this[0].id
  local_network_gateway_id   = azurerm_local_network_gateway.onprem[each.key].id
  shared_key                 = var.onprem_shared_keys[each.key]

  tags = var.tags
}
