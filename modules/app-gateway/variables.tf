variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "public_ip_name" {
  type = string
}

variable "waf_mode" {
  type    = string
  default = "Prevention"

  validation {
    condition     = contains(["Detection", "Prevention"], var.waf_mode)
    error_message = "waf_mode must be either Detection or Prevention."
  }
}

variable "tags" {
  type    = map(string)
  default = {}
}
