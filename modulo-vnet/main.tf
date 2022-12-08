resource "azurerm_virtual_network" "this" {
  address_space       = var.address_space
  location            = var.vnet_location
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
  bgp_community       = var.bgp_community # vazio
  dns_servers         = var.dns_servers   # vazio (?)
  tags                = var.tags

  dynamic "ddos_protection_plan" {
    for_each = var.ddos_protection_plan != null ? [var.ddos_protection_plan] : []

    content {
      enable = ddos_protection_plan.value.enable
      id     = ddos_protection_plan.value.id
    }
  }
}

resource "azurerm_subnet" "public" {
  count = length(var.public_subnet_names)

  address_prefixes                              = [var.subnet_prefixes[count.index]]
  name                                          = var.public_subnet_names[count.index]
  resource_group_name                           = var.resource_group_name
  virtual_network_name                          = azurerm_virtual_network.this.name
  private_endpoint_network_policies_enabled     = lookup(var.subnet_enforce_private_link_endpoint_network_policies, var.public_subnet_names[count.index], false)
  private_link_service_network_policies_enabled = lookup(var.subnet_enforce_private_link_service_network_policies, var.public_subnet_names[count.index], false)
  service_endpoints                             = lookup(var.subnet_service_endpoints, var.public_subnet_names[count.index], null)

  #dynamic "delegation" {
  #  for_each = lookup(var.subnet_delegation, var.public_subnet_names[count.index], {})
  #
  #  content {
  #    name = delegation.key
  #
  #    service_delegation {
  #      name    = lookup(delegation.value, "service_name")
  #      actions = lookup(delegation.value, "service_actions", [])
  #    }
  #  }
  #}
}

resource "azurerm_network_security_group" "this" {
  name                = var.nsg_name
  location            = var.nsg_rg_location
  resource_group_name = var.nsg_rg_name

  tags = {
    environment = var.nsg_tag
  }
}

resource "azurerm_network_security_rule" "public_inbound" {
  name                        = var.sec_rule_name
  description                 = var.sec_rule_description
  priority                    = var.sec_rule_priority
  direction                   = var.sec_rule_direction
  access                      = var.sec_rule_access
  protocol                    = var.sec_rule_protocol
  source_port_range           = var.sec_rule_source_port_range
  destination_port_range      = var.sec_rule_destination_port_range
  source_address_prefix       = var.sec_rule_source_address_prefix
  destination_address_prefix  = var.sec_rule_destination_address_prefix
  resource_group_name         = azurerm_network_security_group.this.resource_group_name
  network_security_group_name = azurerm_network_security_group.this.name
}

resource "azurerm_subnet_network_security_group_association" "public" {
  count = length(azurerm_subnet.public[*].id) # pegar os valores da tupla

  subnet_id                 = azurerm_subnet.public[count.index].id #iterar por string
  network_security_group_id = azurerm_network_security_group.this.id
}



#locals {
#  azurerm_subnets = {
#    for index, subnet in azurerm_subnet.subnet :
#    subnet.name => subnet.id
#  }
#}
#
#resource "azurerm_subnet_network_security_group_association" "vnet" {
#  for_each = var.nsg_ids
#
#  network_security_group_id = each.value
#  subnet_id                 = local.azurerm_subnets[each.key]
#}
#
#resource "azurerm_subnet_route_table_association" "vnet" {
#  for_each = var.route_tables_ids
#
#  route_table_id = each.value
#  subnet_id      = local.azurerm_subnets[each.key]
#}