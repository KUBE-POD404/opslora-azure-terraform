variable "resource_groups" {
  type        = list(string)
  description = "Resource group names to create."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply."
  default     = {}
}

