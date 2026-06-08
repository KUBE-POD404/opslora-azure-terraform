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

