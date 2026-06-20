output "zone_ids" {
  value = { for name, zone in azurerm_private_dns_zone.this : name => zone.id }
}

output "zone_names" {
  value = { for name, zone in azurerm_private_dns_zone.this : name => zone.name }
}

output "onprem_zone_name" {
  value = length(azurerm_private_dns_zone.onprem) > 0 ? azurerm_private_dns_zone.onprem[0].name : null
}

output "onprem_a_records" {
  value = {
    for name, record in azurerm_private_dns_a_record.onprem : name => record.fqdn
  }
}

