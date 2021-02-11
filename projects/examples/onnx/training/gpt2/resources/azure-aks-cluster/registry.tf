resource "azurerm_container_registry" "acr" {
  name                     = var.registryName
  resource_group_name      = azurerm_resource_group.default.name
  location                 = azurerm_resource_group.default.location
  sku                      = "Standard"
  admin_enabled            = true
}

data "azurerm_container_registry" "acr" {
  name                     = azurerm_container_registry.acr.name
  resource_group_name      = azurerm_resource_group.default.name
}

output "registryLocation" {
  value = data.azurerm_container_registry.acr.login_server
}
