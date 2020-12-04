# GKE cluster

# Gets the current version of Kubernetes engine
data "google_container_engine_versions" "gke_version" {
  location = var.clusterRegion
}

resource "google_container_cluster" "primary" {
  name     = var.clusterName
  location = var.clusterRegion
  min_master_version = data.google_container_engine_versions.gke_version.latest_master_version

  remove_default_node_pool = true
  initial_node_count       = var.nodeCount

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  master_auth {
    username = var.gke_username
    password = var.gke_password

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = "${google_container_cluster.primary.name}-node-pool"
  location   = var.clusterRegion
  cluster    = google_container_cluster.primary.name
  node_count = var.gke_num_nodes

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = var.resourceTags
    }

    # preemptible  = true
    machine_type = var.nodeType
    tags         = ["gke-node", var.resourceTags]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}
