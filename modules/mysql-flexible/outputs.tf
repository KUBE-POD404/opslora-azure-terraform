output "id" {
  value = azurerm_mysql_flexible_server.this.id
}

output "fqdn" {
  value = azurerm_mysql_flexible_server.this.fqdn
}

output "administrator_login" {
  value = azurerm_mysql_flexible_server.this.administrator_login
}

output "administrator_password" {
  value     = coalesce(var.administrator_password, random_password.admin[0].result)
  sensitive = true
}

