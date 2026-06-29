output "aks_name" {
  value = module.aks.name
}

output "aks_agic_client_id" {
  value = module.aks.agic_client_id
}

output "app_gateway_id" {
  value = module.app_gateway.id
}

output "key_vault_uri" {
  value = module.key_vault.vault_uri
}

output "aks_key_vault_secrets_provider_client_id" {
  value = module.aks.key_vault_secrets_provider_client_id
}

output "container_registry_name" {
  value = module.container_registry.name
}

output "container_registry_login_server" {
  value = module.container_registry.login_server
}

output "mysql_fqdn" {
  value = module.mysql.fqdn
}

output "managed_grafana_endpoint" {
  value       = module.monitoring.managed_grafana_endpoint
  description = "Azure Managed Grafana endpoint for the test environment."
}

output "managed_grafana_id" {
  value       = module.monitoring.managed_grafana_id
  description = "Azure Managed Grafana resource ID for the test environment."
}

output "monitoring_action_group_id" {
  value       = module.monitoring_alerts.action_group_id
  description = "Azure Monitor action group used by test platform alerts."
}
