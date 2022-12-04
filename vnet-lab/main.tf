resource "random_id" "rg_name" {
  byte_length = 8
}

resource "azurerm_resource_group" "example" {
  location = "East US"
  name     = "test-${random_id.rg_name.hex}-rg"
}

module "vnet" {
  source              = "../modulo-vnet"
  resource_group_name = azurerm_resource_group.example.name
  vnet_location       = "East US"
}

provider "azurerm" {
  features {}
}