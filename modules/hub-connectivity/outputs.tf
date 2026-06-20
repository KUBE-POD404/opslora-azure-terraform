output "vpn_gateway_id" {
  value = azurerm_virtual_network_gateway.this.id
}

output "vpn_gateway_public_ip_address" {
  value = azurerm_public_ip.vpn_gateway.ip_address
}

output "local_network_gateway_ids" {
  value = {
    for site, gateway in azurerm_local_network_gateway.onprem : site => gateway.id
  }
}

output "vpn_connection_ids" {
  value = {
    for site, connection in azurerm_virtual_network_gateway_connection.onprem : site => connection.id
  }
}
