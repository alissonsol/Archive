provider "azurerm" {

  features {}

  # More information on the authentication methods supported by
  # the AzureRM Provider can be found here:
  # http://terraform.io/docs/providers/azurerm/index.html

  # subscription_id = "..."
  # client_id       = "..."
  # client_secret   = "..."
  # tenant_id       = "..."
}

resource "azurerm_resource_group" "default" {
  name     = var.resourceGroup
  location = var.clusterRegion

  tags = {
    environment = var.resourceTags
  }
}
