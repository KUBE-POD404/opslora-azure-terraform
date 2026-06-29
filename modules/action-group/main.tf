variable "name" {
  type        = string
  description = "Action group name."
}

variable "resource_group_name" {
  type        = string
  description = "Monitoring resource group name."
}

variable "short_name" {
  type        = string
  description = "Action group short name."
}

variable "email_receivers" {
  type        = map(string)
  description = "Map of receiver name to email address."
  default     = {}
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags."
}

resource "azurerm_monitor_action_group" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  short_name          = var.short_name
  enabled             = true
  tags                = var.tags

  dynamic "email_receiver" {
    for_each = var.email_receivers
    content {
      name                    = email_receiver.key
      email_address           = email_receiver.value
      use_common_alert_schema = true
    }
  }
}

output "id" {
  value = azurerm_monitor_action_group.this.id
}
