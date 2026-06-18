resource "random_password" "admin" {
  count   = var.administrator_password == null ? 1 : 0
  length  = 24
  special = true
}

resource "azurerm_mysql_flexible_server" "this" {
  name                         = var.name
  location                     = var.location
  resource_group_name          = var.resource_group_name
  administrator_login          = var.administrator_login
  administrator_password       = coalesce(var.administrator_password, random_password.admin[0].result)
  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = var.geo_redundant_backup_enabled
  delegated_subnet_id          = var.delegated_subnet_id
  private_dns_zone_id          = var.private_dns_zone_id
  sku_name                     = var.sku_name
  version                      = var.mysql_version
  zone                         = var.zone
  tags                         = var.tags

  dynamic "high_availability" {
    for_each = var.high_availability.enabled ? [var.high_availability] : []

    content {
      mode                      = high_availability.value.mode
      standby_availability_zone = try(high_availability.value.standby_availability_zone, null)
    }
  }
}

resource "azurerm_mysql_flexible_database" "opslora" {
  name                = "opslora"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.this.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}

