output "workspace_id" {
  value = azurerm_log_analytics_workspace.this.id
}

output "workspace_workspace_id" {
  value = azurerm_log_analytics_workspace.this.workspace_id
}

output "monitor_workspace_id" {
  value = azurerm_monitor_workspace.this.id
}

output "managed_grafana_id" {
  value = try(azurerm_dashboard_grafana.this[0].id, null)
}

output "managed_grafana_endpoint" {
  value = try(azurerm_dashboard_grafana.this[0].endpoint, null)
}

output "managed_grafana_principal_id" {
  value       = try(azurerm_dashboard_grafana.this[0].identity[0].principal_id, null)
  description = "System-assigned managed identity principal ID for Azure Managed Grafana."
}
