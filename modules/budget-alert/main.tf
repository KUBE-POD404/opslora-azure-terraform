variable "subscription_id" {
  type        = string
  description = "Subscription ID for the budget scope."
}

variable "name" {
  type        = string
  description = "Budget resource name."
}

variable "amount" {
  type        = number
  description = "Monthly budget amount in subscription currency."
}

variable "contact_emails" {
  type        = list(string)
  description = "Email recipients for budget notifications."
  default     = []
}

variable "start_date" {
  type        = string
  description = "Budget start date in RFC3339 format. Use the first day of a month."
  default     = "2026-06-01T00:00:00Z"
}

variable "thresholds" {
  type = map(object({
    threshold      = number
    threshold_type = optional(string, "Actual")
    operator       = optional(string, "GreaterThan")
  }))
  description = "Budget notification thresholds keyed by notification name."
  default = {
    actual_50  = { threshold = 50 }
    actual_80  = { threshold = 80 }
    actual_100 = { threshold = 100 }
    forecast_100 = {
      threshold      = 100
      threshold_type = "Forecasted"
    }
  }
}

resource "azurerm_consumption_budget_subscription" "this" {
  name            = var.name
  subscription_id = "/subscriptions/${var.subscription_id}"
  amount          = var.amount
  time_grain      = "Monthly"

  time_period {
    start_date = var.start_date
  }

  dynamic "notification" {
    for_each = var.thresholds
    content {
      enabled        = length(var.contact_emails) > 0
      threshold      = notification.value.threshold
      operator       = notification.value.operator
      threshold_type = notification.value.threshold_type
      contact_emails = var.contact_emails
    }
  }
}
