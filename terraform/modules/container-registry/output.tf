output "name" {
    value = azurerm_container_registry.acr.name
}

output "admin_username" {
    value = azurerm_container_registry.acr.admin_username
}

output "admin_password" {
    value = azurerm_container_registry.acr.admin_password
}

output "login_server" {
    value = "https://${azurerm_container_registry.acr.login_server}"
}