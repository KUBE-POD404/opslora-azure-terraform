variable "subscription_id" {
  type        = string
  description = "Azure subscription ID for opslora-test."
}

variable "hub_subscription_id" {
  type        = string
  description = "Azure subscription ID for opslora-connectivity."
}

variable "tenant_id" {
  type        = string
  description = "Microsoft Entra tenant ID."
}

variable "hub_state_resource_group_name" {
  type        = string
  description = "Terraform state resource group in the hub subscription."
  default     = "rg-opslora-tfstate-cin"
}

variable "hub_state_storage_account_name" {
  type        = string
  description = "Terraform state storage account in the hub subscription."
  default     = "stopsloratfstatecin001"
}

variable "hub_state_container_name" {
  type        = string
  description = "Terraform state blob container."
  default     = "tfstate"
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

variable "kubernetes_version" {
  type        = string
  description = "AKS Kubernetes version. Leave null to use Azure default."
  default     = null
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key for AKS Linux profile."
}

variable "tags" {
  type        = map(string)
  description = "Common tags."
  default = {
    app                = "opslora"
    env                = "test"
    owner              = "platform"
    costCenter         = "opslora"
    dataClassification = "internal"
    managedBy          = "terraform"
  }
}

variable "admin_principal_object_ids" {
  type        = list(string)
  description = "Admin user/group object IDs that receive Owner at the test subscription scope."
  default     = []
}

variable "enable_governance_policy_assignments" {
  type        = bool
  description = "Create audit-mode RBAC/policy governance assignments."
  default     = true
}
