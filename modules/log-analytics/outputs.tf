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
  value = azurerm_dashboard_grafana.this.id
}

output "managed_grafana_endpoint" {
  value = azurerm_dashboard_grafana.this.endpoint
}
