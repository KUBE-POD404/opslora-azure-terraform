output "aks_name" {
  value = module.aks.name
}

output "app_gateway_id" {
  value = module.app_gateway.id
}

output "key_vault_uri" {
  value = module.key_vault.vault_uri
}

output "mysql_fqdn" {
  value = module.mysql.fqdn
}

