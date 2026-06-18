output "aks_name" {
  value = module.aks.name
}

output "aks_agic_client_id" {
  value = module.aks.agic_client_id
}

output "app_gateway_id" {
  value = module.app_gateway.id
}

output "app_gateway_public_ip_address" {
  value = module.app_gateway.public_ip_address
}

output "key_vault_uri" {
  value = module.key_vault.vault_uri
}

output "aks_key_vault_secrets_provider_client_id" {
  value = module.aks.key_vault_secrets_provider_client_id
}

output "mysql_fqdn" {
  value = module.mysql.fqdn
}
