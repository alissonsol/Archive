output "registryLocation" {
  value = data.azurerm_container_registry.acr.login_server
}
