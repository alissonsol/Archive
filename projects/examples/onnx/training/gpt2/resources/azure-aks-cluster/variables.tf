variable "clusterDnsPrefix" {
  description = "Cluster DNS prefix"
}

variable "clusterName" {
  description = "Cluster name"
}

variable "clusterRegion" {
  description = "Cluster region"
}

variable "clusterVersion" {
  description = "Cluster Kubernetes version"
}

variable "nodeCount" {
  description = "Node count (initial)"
}

variable "nodeType" {
  description = "Node type (vm size)"
}

variable "registryName" {
  description = "Container registry name"
}

variable "resourceGroup" {
  description = "Resource group"
}

variable "resourceTags" {
  description = "Resource tags (dev, test, prod, etc.)"
}

variable "frontendIpName" {
  description = "Frontend IP name"
}