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

resource "azurerm_subnet" "this" {
  count = length(var.subnet_names)

  address_prefixes                              = [var.subnet_prefixes[count.index]]
  name                                          = var.subnet_names[count.index]
  resource_group_name                           = var.resource_group_name
  virtual_network_name                          = azurerm_virtual_network.this.name
  private_endpoint_network_policies_enabled     = lookup(var.subnet_enforce_private_link_endpoint_network_policies, var.subnet_names[count.index], false)
  private_link_service_network_policies_enabled = lookup(var.subnet_enforce_private_link_service_network_policies, var.subnet_names[count.index], false)
  service_endpoints                             = lookup(var.subnet_service_endpoints, var.subnet_names[count.index], null)

  #dynamic "delegation" {
  #  for_each = lookup(var.subnet_delegation, var.subnet_names[count.index], {})
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

#resource "azurerm_network_security_group" "this" {
#  name                = var.nsg_name
#  location            = var.nsg_rg_location
#  resource_group_name = var.nsg_rg_name
#
#  security_rule {
#    name                       = var.nsg_sec_rule_name
#    priority                   = var.nsg_sec_rule_priority
#    direction                  = var.nsg_sec_rule_direction
#    access                     = var.nsg_sec_rule_access 
#    protocol                   = var.nsg_sec_rule_protocol
#    source_port_range          = var.nsg_sec_rule_source_port_range
#    destination_port_range     = var.nsg_sec_rule_destination_port_range
#    source_address_prefix      = var.nsg_sec_rule_source_address_prefix
#    destination_address_prefix = var.nsg_sec_rule_destination_address_prefix
#  }
#
#  tags = {
#    environment = var.nsg_tag
#  }
#}

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