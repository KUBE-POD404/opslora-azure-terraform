output "vpn_gateway_id" {
  value = azurerm_virtual_network_gateway.this.id
}

output "vpn_gateway_public_ip_address" {
  value = azurerm_public_ip.vpn_gateway.ip_address
}
