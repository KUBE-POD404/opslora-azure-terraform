locals {
  name_prefix = "${var.prefix}-${var.env}-${var.location_code}"

  alert_scopes = [var.aks_cluster_id]

  aks_metric_namespace = "Microsoft.ContainerService/managedClusters"

  alert_tags = merge(var.tags, {
    component = "observability"
    managedBy = "terraform"
  })
}

resource "azurerm_monitor_action_group" "platform" {
  name                = "ag-${local.name_prefix}-platform-alerts"
  resource_group_name = var.resource_group_name
  short_name          = "${var.env}ops"
  enabled             = true
  tags                = local.alert_tags

  dynamic "email_receiver" {
    for_each = var.alert_email_receivers

    content {
      name                    = email_receiver.key
      email_address           = email_receiver.value
      use_common_alert_schema = true
    }
  }
}

resource "azurerm_monitor_metric_alert" "aks_node_cpu_high" {
  name                = "ma-${local.name_prefix}-aks-node-cpu-high"
  resource_group_name = var.resource_group_name
  scopes              = local.alert_scopes
  description         = "AKS node CPU usage is above 85% for 15 minutes."
  severity            = 2
  enabled             = var.enabled
  frequency           = "PT5M"
  window_size         = "PT15M"
  tags                = local.alert_tags

  criteria {
    metric_namespace = local.aks_metric_namespace
    metric_name      = "node_cpu_usage_percentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 85
  }

  action {
    action_group_id = azurerm_monitor_action_group.platform.id
  }
}

resource "azurerm_monitor_metric_alert" "aks_node_memory_high" {
  name                = "ma-${local.name_prefix}-aks-node-memory-high"
  resource_group_name = var.resource_group_name
  scopes              = local.alert_scopes
  description         = "AKS node memory working set is above 90% for 15 minutes."
  severity            = 2
  enabled             = var.enabled
  frequency           = "PT5M"
  window_size         = "PT15M"
  tags                = local.alert_tags

  criteria {
    metric_namespace = local.aks_metric_namespace
    metric_name      = "node_memory_working_set_percentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 90
  }

  action {
    action_group_id = azurerm_monitor_action_group.platform.id
  }
}

resource "azurerm_monitor_metric_alert" "aks_node_disk_high" {
  name                = "ma-${local.name_prefix}-aks-node-disk-high"
  resource_group_name = var.resource_group_name
  scopes              = local.alert_scopes
  description         = "AKS node disk usage is above 90% for 15 minutes."
  severity            = 3
  enabled             = var.enabled
  frequency           = "PT5M"
  window_size         = "PT15M"
  tags                = local.alert_tags

  criteria {
    metric_namespace = local.aks_metric_namespace
    metric_name      = "node_disk_usage_percentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 90
  }

  action {
    action_group_id = azurerm_monitor_action_group.platform.id
  }
}

resource "azurerm_monitor_metric_alert" "aks_unschedulable_pods" {
  name                = "ma-${local.name_prefix}-aks-unschedulable-pods"
  resource_group_name = var.resource_group_name
  scopes              = local.alert_scopes
  description         = "AKS cluster autoscaler sees unschedulable pods."
  severity            = 2
  enabled             = var.enabled
  frequency           = "PT5M"
  window_size         = "PT15M"
  tags                = local.alert_tags

  criteria {
    metric_namespace = local.aks_metric_namespace
    metric_name      = "cluster_autoscaler_unschedulable_pods_count"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 0
  }

  action {
    action_group_id = azurerm_monitor_action_group.platform.id
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "workload_restarts" {
  name                 = "sqa-${local.name_prefix}-workload-restarts"
  resource_group_name  = var.resource_group_name
  location             = var.location
  scopes               = [var.log_analytics_workspace_id]
  description          = "Pods in Opslora or Argo CD namespaces restarted in the last 10 minutes."
  severity             = 2
  enabled              = var.enabled
  evaluation_frequency = "PT5M"
  window_duration      = "PT10M"
  tags                 = local.alert_tags

  criteria {
    query                   = <<-KQL
      KubePodInventory
      | where TimeGenerated > ago(10m)
      | where ClusterName == "${var.aks_cluster_name}"
      | where Namespace in ("opslora-app-ns", "argocd")
      | summarize RestartCount=sum(ContainerRestartCount)
      | project RestartCount
    KQL
    time_aggregation_method = "Maximum"
    metric_measure_column   = "RestartCount"
    operator                = "GreaterThan"
    threshold               = 0

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.platform.id]
    email_subject = "Opslora ${var.env}: workload restarts detected"
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "failed_or_pending_pods" {
  name                 = "sqa-${local.name_prefix}-failed-pending-pods"
  resource_group_name  = var.resource_group_name
  location             = var.location
  scopes               = [var.log_analytics_workspace_id]
  description          = "Pods in Opslora or Argo CD namespaces are Failed, Pending, or Unknown."
  severity             = 2
  enabled              = var.enabled
  evaluation_frequency = "PT5M"
  window_duration      = "PT10M"
  tags                 = local.alert_tags

  criteria {
    query                   = <<-KQL
      KubePodInventory
      | where TimeGenerated > ago(10m)
      | where ClusterName == "${var.aks_cluster_name}"
      | where Namespace in ("opslora-app-ns", "argocd")
      | where PodStatus in ("Failed", "Pending", "Unknown")
      | summarize ProblemPods=dcount(Name)
      | project ProblemPods
    KQL
    time_aggregation_method = "Maximum"
    metric_measure_column   = "ProblemPods"
    operator                = "GreaterThan"
    threshold               = 0

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.platform.id]
    email_subject = "Opslora ${var.env}: failed or pending pods detected"
  }
}
