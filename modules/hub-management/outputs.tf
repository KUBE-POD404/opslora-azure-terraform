output "bastion_id" {
  value = try(azurerm_bastion_host.this[0].id, null)
}

output "bastion_public_ip_address" {
  value = try(azurerm_public_ip.bastion[0].ip_address, null)
}
