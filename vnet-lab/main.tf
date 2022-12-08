module "vnet" {
  source                              = "../modulo-vnet"
  resource_group_name                 = "rg-lab"
  vnet_name                           = "lab-vnet"
  vnet_location                       = "East US"
  nsg_rg_location                     = "East US"
  nsg_rg_name                         = "rg-lab"
  public_subnet_names                 = ["public-subnet-a", "public-subnet-b"]
  subnet_prefixes                     = ["10.0.1.0/24", "10.0.2.0/24"]
  sec_rule_name                       = "allow-80"
  sec_rule_priority                   = 300
  sec_rule_destination_port_range     = "80"
  sec_rule_source_address_prefix      = ""
  sec_rule_destination_address_prefix = ""
  sec_rule_description                = "Allow only 80 tcp ip port from gilver's home"
}

provider "azurerm" {
  features {}
}