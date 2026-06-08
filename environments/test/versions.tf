terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-opslora-tfstate-cin"
    storage_account_name = "stopsloratfstatecin001"
    container_name       = "tfstate"
    key                  = "test/terraform.tfstate"
    use_azuread_auth     = true
  }
}

