module "vnet" {
  source              = "../modulo-vnet"
  resource_group_name = "rg-lab"
  vnet_name           = "lab-vnet"
  vnet_location       = "East US"
  nsg_rg_location     = "East US"
  nsg_rg_name         = "rg-lab"
  subnet_names        = ["subnet-a", "subnet-b"]
  subnet_prefixes     = ["10.0.1.0/24", "10.0.2.0/24"]
}

provider "azurerm" {
  features {}
}