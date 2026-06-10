variable "subscription_id" {
  type        = string
  description = "Azure subscription ID for opslora-connectivity."
}

variable "tenant_id" {
  type        = string
  description = "Microsoft Entra tenant ID."
}

variable "location" {
  type        = string
  description = "Primary Azure region."
  default     = "centralindia"
}

variable "location_code" {
  type        = string
  description = "Short region code."
  default     = "cin"
}

variable "tags" {
  type        = map(string)
  description = "Common tags."
  default = {
    app                = "opslora"
    env                = "hub"
    owner              = "platform"
    costCenter         = "opslora"
    dataClassification = "internal"
    managedBy          = "terraform"
  }
}

variable "admin_principal_object_ids" {
  type        = list(string)
  description = "Admin user/group object IDs that receive Owner at the hub subscription scope."
  default     = []
}

variable "enable_governance_policy_assignments" {
  type        = bool
  description = "Create audit-mode RBAC/policy governance assignments."
  default     = true
}
