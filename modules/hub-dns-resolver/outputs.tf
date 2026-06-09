output "resolver_id" {
  value = azurerm_private_dns_resolver.this.id
}

output "inbound_endpoint_ip" {
  value = azurerm_private_dns_resolver_inbound_endpoint.this.ip_configurations[0].private_ip_address
}

output "outbound_endpoint_id" {
  value = azurerm_private_dns_resolver_outbound_endpoint.this.id
}
