output "kubernetes_cluster_name" {
  value       = google_container_cluster.primary.name
  description = "GKE Cluster Name"
}

output "kubernetes_cluster_min_master_version" {
  value       = google_container_cluster.primary.min_master_version
  description = "GKE Cluster Min Master Version"
}

output "registryLocation" {
  value = data.google_container_registry_repository.registry.repository_url
}