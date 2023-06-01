# main.tf file of network-interface module
resource "azurerm_network_interface" "nic" {
    name                = var.name
    location            = var.location
    resource_group_name = var.resource_group_name
    ip_configuration {
        name                          = "ipconfiguration1"
        subnet_id                     = var.subnet_id
        private_ip_address_allocation = var.public-ip-id == "" ? "Dynamic" : "Static"
        public_ip_address_id = var.public-ip-id == "" ? null : var.public-ip-id
    }
}