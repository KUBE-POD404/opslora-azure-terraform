output "hub_vnet_id" {
  value = module.hub_network.vnet_id
}

output "hub_vnet_name" {
  value = module.hub_network.vnet_name
}

output "hub_network_resource_group_name" {
  value = module.resource_groups.names["rg-opslora-hub-network-cin"]
}

output "private_dns_zone_ids" {
  value = module.private_dns.zone_ids
}

output "onprem_private_dns_zone_name" {
  value = module.private_dns.onprem_zone_name
}

output "onprem_private_dns_a_records" {
  value = module.private_dns.onprem_a_records
}

output "log_analytics_workspace_id" {
  value = module.monitoring.workspace_id
}

output "firewall_private_ip" {
  value = module.hub_security.firewall_private_ip
}

output "firewall_public_ip_address" {
  value = module.hub_security.firewall_public_ip_address
}

output "bastion_public_ip_address" {
  value = module.hub_management.bastion_public_ip_address
}

output "vpn_gateway_public_ip_address" {
  value = module.hub_connectivity.vpn_gateway_public_ip_address
}

output "dns_resolver_inbound_ip" {
  value = module.hub_dns_resolver.inbound_endpoint_ip
}
