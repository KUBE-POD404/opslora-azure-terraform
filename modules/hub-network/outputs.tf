output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "vnet_name" {
  value = azurerm_virtual_network.this.name
}

output "subnet_ids" {
  value = {
    AzureFirewallSubnet           = azurerm_subnet.firewall.id
    GatewaySubnet                 = azurerm_subnet.gateway.id
    AzureBastionSubnet            = azurerm_subnet.bastion.id
    snet-dns-resolver-inbound     = azurerm_subnet.dns_inbound.id
    snet-dns-resolver-outbound    = azurerm_subnet.dns_outbound.id
    snet-shared-private-endpoints = azurerm_subnet.shared_private_endpoints.id
  }
}

