variable "azureRegion" {
  description = "Azure Region"
}

variable "azureResourceGroup" {
  description = "Azure Resource group"
}

variable "azureResourceTagEnvironment" {
  description = "Azure Resource Tag for environment (dev, test, prod)"
}

variable "clusterDnsPrefix" {
  description = "Cluster DNS prefix"
}

variable "clusterName" {
  description = "Cluster name"
}

variable "clusterVersion" {
  description = "Cluster Kubernetes version"
}

variable "registryName" {
  description = "Container Registry name"
}
