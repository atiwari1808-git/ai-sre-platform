# infra/gke.tf

# 1. Enable the GCP APIs our project needs
resource "google_project_service" "services" {
  for_each = toset([
    "container.googleapis.com",           # GKE
    "artifactregistry.googleapis.com",    # Image storage
  ])
  service            = each.key
  disable_on_destroy = false
}

# 2. Artifact Registry: a private repo to store our Docker images
resource "google_artifact_registry_repository" "repo" {
  location      = var.region
  repository_id = "ai-sre-images"
  format        = "DOCKER"
  depends_on    = [google_project_service.services]
}

# 3. The GKE cluster itself
resource "google_container_cluster" "primary" {
  name = "ai-sre-cluster"

  # CHANGED: zonal instead of regional. "us-central1" spreads nodes across
  # 3 zones (3x the disk); pinning to one zone keeps it to a single node.
  location = "${var.region}-a"

  # We remove the default node pool and add our own (best practice)
  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false
  depends_on               = [google_project_service.services]

  # ADDED: the temporary default node pool created during cluster bring-up
  # ignores the node_config below and defaults to 100GB pd-balanced disks,
  # which count against SSD_TOTAL_GB. Force it onto standard (HDD) disks.
  node_config {
    disk_size_gb = 30
    disk_type    = "pd-standard"
  }
}

# 4. A small, cheap node pool (the VMs that run your pods)
resource "google_container_node_pool" "primary_nodes" {
  name = "primary-node-pool"

  # CHANGED: must match the cluster's zonal location
  location   = "${var.region}-a"
  cluster    = google_container_cluster.primary.name
  node_count = 1                      # just ONE node to keep costs low

  node_config {
    machine_type = "e2-small"         # small, inexpensive VM
    disk_size_gb = 30
    disk_type    = "pd-standard"      # ADDED: avoids SSD_TOTAL_GB quota
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

