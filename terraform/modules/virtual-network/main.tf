resource "azurerm_virtual_network" "vnet" {
  name                = var.virtual-network-name
  resource_group_name = var.resource-group-name
  location            = var.resource-group-location
  address_space       = [var.address-space]
}