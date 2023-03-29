terraform {
  backend "azurerm" {}

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "3.40"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.25"
    }
  }
}
