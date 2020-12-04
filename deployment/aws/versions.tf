# https://registry.terraform.io/providers/hashicorp/aws/latest

terraform {
  required_version = ">= 0.14"

 required_providers {
    aws = {
      version = "~> 3.20.0"
      source = "hashicorp/aws"
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
