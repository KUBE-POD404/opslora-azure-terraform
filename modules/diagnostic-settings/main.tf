variable "diagnostic_settings" {
  description = "Diagnostic settings keyed by logical resource name. Categories must be valid for the target resource type."
  type = map(object({
    target_resource_id = string
    log_categories     = optional(set(string), [])
    metric_categories  = optional(set(string), ["AllMetrics"])
  }))
  default = {}
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Destination Log Analytics workspace resource ID."
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  for_each = var.diagnostic_settings

  name                       = "diag-${each.key}"
  target_resource_id         = each.value.target_resource_id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = each.value.log_categories
    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = each.value.metric_categories
    content {
      category = enabled_metric.value
    }
  }
}
