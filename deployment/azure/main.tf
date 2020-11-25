provider "azurerm" {
  version = "~> 2.36.0"
  features {}
}

resource "azurerm_resource_group" "default" {
  name     = var.azureResourceGroup
  location = var.azureRegion

  tags = {
    environment = var.azureResourceTagEnvironment
  }
}
