resource "azurerm_subnet" "asn-public" {
  name                 = var.subnet-name
  resource_group_name  = var.resource-group-name
  virtual_network_name = var.virtual-network-name
  address_prefixes     = [var.address-prefixes]
}