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

variable "gke_username" {
  default     = ""
  description = "gke username"
}

variable "gke_password" {
  default     = ""
  description = "gke password"
}

variable "gke_num_nodes" {
  default     = 1
  description = "number of gke nodes"
}