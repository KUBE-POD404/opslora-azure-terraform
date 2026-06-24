variable "subscription_id" {
  type        = string
  description = "Azure subscription ID for opslora-prod."
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
    env                = "prod"
    owner              = "platform"
    costCenter         = "opslora"
    dataClassification = "confidential"
    managedBy          = "terraform"
  }
}

variable "admin_principal_object_ids" {
  type        = list(string)
  description = "Admin group object IDs that receive Owner when explicitly enabled."
  default     = []
}

variable "enable_admin_owner_role_assignments" {
  type        = bool
  description = "Enable subscription Owner assignments for admin_principal_object_ids. Keep false unless approved."
  default     = false
}

variable "enable_governance_policy_assignments" {
  type        = bool
  description = "Create prod governance policy assignments."
  default     = true
}

variable "prod_private_cluster_enabled" {
  type        = bool
  description = "Whether prod AKS uses a private API server."
  default     = false
}

variable "rbac_group_object_ids" {
  type        = map(string)
  description = "Imported Microsoft Entra group object IDs keyed by Opslora group name."
  default     = {}
}

variable "enable_rbac_assignments" {
  type        = bool
  description = "Create resource-group scoped RBAC assignments from rbac_group_object_ids."
  default     = false
}

variable "prod_github_actions_oidc_object_id" {
  type        = string
  description = "Microsoft Entra service principal object ID used by GitHub Actions OIDC for prod workflows that seed Key Vault secrets."
  default     = "5e057103-ed39-4bbd-bd57-c1fe8aae0925"
}
