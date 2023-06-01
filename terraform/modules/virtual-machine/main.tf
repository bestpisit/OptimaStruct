resource "azurerm_linux_virtual_machine" "example" {
  name                = var.name
  resource_group_name = var.resource-group-name
  location            = var.location
  size                = "Standard_B2S"
  admin_username      = var.admin-username
  network_interface_ids = [
    var.nic-id
  ]

  admin_password = var.admin-password
  disable_password_authentication = false

  admin_ssh_key {
    username   = var.admin-username
    public_key = file("./id_rsa.pub.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
