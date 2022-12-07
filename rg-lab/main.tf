module "vnet" {
  source      = "../modulo-rg"
  rg_name     = "rg-lab"
  rg_location = "East US"
}
