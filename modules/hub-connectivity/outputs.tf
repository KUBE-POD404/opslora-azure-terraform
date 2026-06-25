output "vpn_gateway_id" {
  value = try(azurerm_virtual_network_gateway.this[0].id, null)
}

output "vpn_gateway_public_ip_address" {
  value = try(azurerm_public_ip.vpn_gateway[0].ip_address, null)
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
