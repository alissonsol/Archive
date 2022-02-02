# https://registry.terraform.io/providers/hashicorp/aws/latest

terraform {
  required_version = ">= 1.1"

  required_providers {
    aws = {
      version = "~> 3.74.0"
      source = "hashicorp/aws"
    }
    kubernetes = {
      version = "~> 2.7.1"
      source = "hashicorp/kubernetes"
    }
    local = {
      version = "~> 2.1.0"
      source = "hashicorp/local"
    }
    null = {
      version = "~> 3.1.0"
      source = "hashicorp/null"
    }
    random = {
      version = "~> 3.1.0"
      source = "hashicorp/random"
    }
    template = {
      version = "~> 2.2.0"
      source = "hashicorp/template"
    }
  }  
}
