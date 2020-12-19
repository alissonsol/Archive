# VPC
resource "google_compute_network" "vpc" {
  name                    = var.clusterName
  auto_create_subnetworks = "false"
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = var.clusterName
  region        = var.clusterRegion
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.0.0/24"

}

output "region" {
  value       = var.clusterRegion
  description = "region"
}
