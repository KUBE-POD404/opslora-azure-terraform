output "action_group_id" {
  value       = azurerm_monitor_action_group.platform.id
  description = "Azure Monitor action group ID for platform alerts."
}

output "metric_alert_ids" {
  value = {
    aks_node_cpu_high      = azurerm_monitor_metric_alert.aks_node_cpu_high.id
    aks_node_memory_high   = azurerm_monitor_metric_alert.aks_node_memory_high.id
    aks_node_disk_high     = azurerm_monitor_metric_alert.aks_node_disk_high.id
    aks_unschedulable_pods = azurerm_monitor_metric_alert.aks_unschedulable_pods.id
  }
  description = "Metric alert resource IDs."
}

output "log_alert_ids" {
  value = {
    workload_restarts      = azurerm_monitor_scheduled_query_rules_alert_v2.workload_restarts.id
    failed_or_pending_pods = azurerm_monitor_scheduled_query_rules_alert_v2.failed_or_pending_pods.id
  }
  description = "Scheduled query alert resource IDs."
}
