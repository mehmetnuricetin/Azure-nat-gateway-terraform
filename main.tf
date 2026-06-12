terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    # Note: Carl references a custom identity provider written by Simon Golag 
    # to fetch Azure CLI credentials without persisting subscription IDs to state.
  }
}

provider "azurerm" {
  features {}
}

# Resource Group using string interpolation for naming conventions
resource "azurerm_resource_group" "this" {
  name     = "rg-${var.environment}-${var.location_short}-${var.common_name}"
  location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "this" {
  name                = "vnet-${var.environment}-${var.location_short}-${var.common_name}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

# Subnet
resource "azurerm_subnet" "internal" {
  name                 = "sn-internal"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Public IP Address (Standard & Static are requirements for NAT Gateway)
resource "azurerm_public_ip" "this" {
  name                = "pip-${var.environment}-${var.location_short}-${var.common_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1"]
}

# NAT Gateway (Explicitly matched to Zone 1 alongside the Public IP)
resource "azurerm_nat_gateway" "this" {
  name                    = "ngw-${var.environment}-${var.location_short}-${var.common_name}"
  location                = azurerm_resource_group.this.location
  resource_group_name     = azurerm_resource_group.this.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 4
  zones                   = ["1"]
}

# Glue resource: Associating the Public IP to the NAT Gateway
resource "azurerm_nat_gateway_public_ip_association" "this" {
  nat_gateway_id       = azurerm_nat_gateway.this.id
  public_ip_address_id = azurerm_public_ip.this.id
}

# Glue resource: Associating the Subnet to the NAT Gateway
resource "azurerm_subnet_nat_gateway_association" "this" {
  subnet_id      = azurerm_subnet.internal.id
  nat_gateway_id = azurerm_nat_gateway.this.id
}