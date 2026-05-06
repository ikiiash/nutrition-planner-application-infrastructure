terraform {
  required_version = ">= 1.14.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.64"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-fsa-tfstate"
    storage_account_name = "fsafstate"
    container_name       = "tfstate"
    key                  = "fsa/pip/terraform.tfstate"
  }
}
