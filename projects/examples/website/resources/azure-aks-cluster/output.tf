output "registryLocation" {
  value = data.azurerm_container_registry.acr.login_server
}

output "frontendIpAddress" {
  value = data.azurerm_public_ip.frontendIp.ip_address
}