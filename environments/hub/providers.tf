provider "azurerm" {
  features {
    resource_group {
      # Full reset workflows intentionally delete Terraform-managed resource groups
      # even when Azure-created child resources (for example ContainerInsights solutions)
      # remain after parent resources are destroyed.
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

