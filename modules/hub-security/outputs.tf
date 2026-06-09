output "firewall_id" {
  value = azurerm_firewall.this.id
}

output "firewall_private_ip" {
  value = azurerm_firewall.this.ip_configuration[0].private_ip_address
}

output "firewall_public_ip_address" {
  value = azurerm_public_ip.firewall.ip_address
}

output "firewall_policy_id" {
  value = azurerm_firewall_policy.this.id
}

output "public_ip_prefix_id" {
  value = azurerm_public_ip_prefix.hub.id
}
