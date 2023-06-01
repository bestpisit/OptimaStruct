resource "azurerm_virtual_network_peering" "peering" {
  name                      = var.name
  resource_group_name       = var.resource-group-name
  virtual_network_name      = var.vnet-name
  remote_virtual_network_id = var.vnet-id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}
