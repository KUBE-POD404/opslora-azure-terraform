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

output "log_analytics_workspace_id" {
  value = module.monitoring.workspace_id
}

