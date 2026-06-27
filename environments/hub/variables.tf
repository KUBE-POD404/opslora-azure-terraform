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


variable "enable_bastion" {
  description = "Create Azure Bastion resources. Default is false because Bastion is temporary and should stay down unless explicitly needed."
  type        = bool
  default     = false
}

variable "enable_vpn_gateway" {
  description = "Create Azure native S2S VPN Gateway resources. Default is false because Opslora uses Tailscale for Azure-to-local AI connectivity."
  type        = bool
  default     = false
}

variable "onprem_sites" {
  description = "Site-to-site VPN peers for on-prem/hybrid workloads. Provide real endpoint values via secure untracked tfvars or GitHub Actions variables."
  type = map(object({
    gateway_address = string
    address_spaces  = list(string)
  }))
  default = {}
}

variable "onprem_shared_keys" {
  description = "IPsec shared keys by onprem_sites key. Provide real values via secure untracked tfvars or GitHub Actions secrets."
  type        = map(string)
  sensitive   = true
  default     = {}
}

variable "onprem_private_dns_zone_name" {
  description = "Private DNS zone used for stable names for on-prem workloads reachable from Azure over VPN."
  type        = string
  default     = "onprem.opslora.internal"
}

variable "onprem_a_records" {
  description = "Stable A records for on-prem workload endpoints, keyed by host label. Example: ai-gateway = 172.16.10.10."
  type        = map(string)
  default     = {}
}
