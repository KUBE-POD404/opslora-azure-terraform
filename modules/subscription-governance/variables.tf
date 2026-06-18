variable "subscription_id" {
  type        = string
  description = "Azure subscription ID where governance is applied."
}

variable "location" {
  type        = string
  description = "Azure location for subscription policy assignments."
}

variable "scope_name" {
  type        = string
  description = "Short scope name used in policy assignment names, for example hub or test."
}

variable "admin_principal_object_ids" {
  type        = list(string)
  description = "Admin user or group object IDs that should receive Owner at subscription scope."
  default     = []
}

variable "enable_admin_owner_role_assignments" {
  type        = bool
  description = "Whether to create subscription Owner role assignments for admin_principal_object_ids. Keep false when Owner is already assigned outside Terraform."
  default     = false
}

variable "enable_policy_assignments" {
  type        = bool
  description = "Whether to create audit-mode subscription policy assignments."
  default     = true
}

variable "policy_effect" {
  type        = string
  description = "Default effect for Opslora custom policies. Use Audit in test and Deny in prod after readiness checks."
  default     = "Audit"

  validation {
    condition     = contains(["Audit", "Deny", "Disabled"], var.policy_effect)
    error_message = "policy_effect must be Audit, Deny, or Disabled."
  }
}

variable "key_vault_public_network_effect" {
  type        = string
  description = "Effect for the built-in Key Vault public network policy."
  default     = "Audit"

  validation {
    condition     = contains(["Audit", "Deny", "Disabled"], var.key_vault_public_network_effect)
    error_message = "key_vault_public_network_effect must be Audit, Deny, or Disabled."
  }
}

variable "aks_workload_identity_effect" {
  type        = string
  description = "Effect for the built-in AKS Workload Identity policy."
  default     = "Audit"

  validation {
    condition     = contains(["Audit", "Deny", "Disabled"], var.aks_workload_identity_effect)
    error_message = "aks_workload_identity_effect must be Audit, Deny, or Disabled."
  }
}

variable "allowed_locations" {
  type        = list(string)
  description = "Approved Azure locations. Include global for global resources such as DNS."
  default     = ["centralindia", "southindia", "global"]
}

variable "required_tags" {
  type        = list(string)
  description = "Tags audited on resources."
  default = [
    "env",
    "owner",
    "costCenter",
    "app",
    "dataClassification",
    "managedBy",
  ]
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to policy assignments where supported."
  default     = {}
}
