resource "azurerm_public_ip" "frontendIp" {
  name                = var.frontendIpName
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  allocation_method   = "Static"
}

data "azurerm_public_ip" "frontendIp" {
  name                     = var.frontendIpName
  resource_group_name      = azurerm_resource_group.default.name
}
