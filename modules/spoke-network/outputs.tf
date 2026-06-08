output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "vnet_name" {
  value = azurerm_virtual_network.this.name
}

output "subnet_ids" {
  value = {
    snet-aks-system        = azurerm_subnet.aks_system.id
    snet-aks-apps          = azurerm_subnet.aks_apps.id
    snet-mysql-flexible    = azurerm_subnet.mysql_flexible.id
    snet-private-endpoints = azurerm_subnet.private_endpoints.id
    snet-ingress           = azurerm_subnet.ingress.id
  }
}

