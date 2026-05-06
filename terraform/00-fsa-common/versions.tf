terraform {
  required_version = ">= 1.14.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.64"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.8"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.8"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-fsa-tfstate"
    storage_account_name = "fsafstate"
    container_name       = "tfstate"
    key                  = "fsa/common/terraform.tfstate"
  }
}
