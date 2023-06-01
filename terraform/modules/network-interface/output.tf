# outputs.tf file of network-interface module
output "nic_id" {
    description = "id of the network interface"
    value = azurerm_network_interface.nic.id
}