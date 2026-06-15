terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "this" {
  name     = "rg-drift-demo"
  location = "swedencentral"
}

resource "random_string" "storage_suffix" {
  length  = 10
  upper   = false
  special = false
}

resource "azurerm_storage_account" "this" {
  name                     = "drift${random_string.storage_suffix.result}"
  location                 = azurerm_resource_group.this.location
  resource_group_name      = azurerm_resource_group.this.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}