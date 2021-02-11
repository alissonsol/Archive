# https://registry.terraform.io/providers/hashicorp/azurerm/latest

terraform {
  required_version = ">= 0.14"

  required_providers {
    azurerm = {
      version = "~> 2.39.0"
      source = "hashicorp/azurerm"
    }
    kubernetes = {
      version = "~> 1.13.3"
      source = "hashicorp/kubernetes"
    }
    local = {
      version = "~> 2.0.0"
      source = "hashicorp/local"
    }
    null = {
      version = "~> 3.0.0"
      source = "hashicorp/null"
    }
    random = {
      version = "~> 3.0.0"
      source = "hashicorp/random"
    }
    template = {
      version = "~> 2.2.0"
      source = "hashicorp/template"
    }
  }  
}
