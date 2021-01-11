resource "azurerm_public_ip" "frontendIp" {
  name                = var.frontendIpName
  resource_group_name = azurerm_kubernetes_cluster.default.node_resource_group
  location            = azurerm_kubernetes_cluster.default.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

data "azurerm_public_ip" "frontendIp" {
  name                     = azurerm_public_ip.frontendIp.name
  resource_group_name      = azurerm_public_ip.frontendIp.resource_group_name
}

# Reference: https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/data_source
data "external" "originalIp" {
  program = [
    "pwsh",
    "./public_ip.ps1",
    azurerm_kubernetes_cluster.default.node_resource_group,
  ]

  query = {
    dummy = data.azurerm_public_ip.frontendIp.ip_address   
  }
}

output "frontendIpAddress" {
  value = data.azurerm_public_ip.frontendIp.ip_address
}

output "clusterIpAddress" {
  value = data.external.originalIp.result.ip_address
}