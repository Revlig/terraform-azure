locals {
  network_sec_rules = {
    public_inbound = [
      {
        name                       = "Allow-80"
        description                = "Allow http port from internet"
        priority                   = 600
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = ""
        destination_address_prefix = "192.168.5.5/32"
      },
      {
        name                       = "Allow-443"
        description                = "Allow https port from internet"
        priority                   = 610
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = ""
        destination_address_prefix = "20.81.106.225"
      },
      {
        name                       = "Allow-1443"
        description                = "Allow 1443 port from internet"
        priority                   = 620
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "1443"
        source_address_prefix      = ""
        destination_address_prefix = "20.81.106.225"
      }
    ]
  }


}

module "vnet" {
  source                   = "../modulo-vnet"
  resource_group_name      = "rg-lab"
  vnet_name                = "lab-vnet"
  vnet_location            = "East US"
  nsg_rg_location          = "East US"
  nsg_rg_name              = "rg-lab"
  public_subnet_names      = ["public-subnet-a", "public-subnet-b"]
  public_subnet_prefixes   = ["10.0.1.0/24", "10.0.2.0/24"]
  public_inbound_nsg_rules = local.network_sec_rules["public_inbound"]
}

provider "azurerm" {
  features {}
}