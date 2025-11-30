
terraform {
  source = "github.com/terasky-int/training-modules.git//modules/gke-cluster"
}

include "shared" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "gke-network" {
  config_path = "../get-subnet-network-links"
}

inputs = {
  sufix        = ""
  network      = dependency.gke-network.outputs.network
  subnetwork   = dependency.gke-network.outputs.subnetwork
  private_tag  = "private"
  machine_type = "n2d-standard-2"
  preemptible  = false
  spot         = true

  node_locations = [
    "${include.shared.inputs.region}-a",
    "${include.shared.inputs.region}-b",
    "${include.shared.inputs.region}-c",
  ]
  # Kubernetes master and nodes version can be set here
  kubernetes_nodes_version = "1.33.5-gke.1125000"
  kubernetes_version       = "1.33.5-gke.1125000"
  name                     = "${include.shared.inputs.prefix}-gke-${include.shared.inputs.glb_name}"
  # Autoscaling variables
  nodepool_config = {
    autoscaling = {
      use_total_nodes = true
      min_node_count  = 0
      max_node_count  = 2
    }
    management = {
      auto_repair  = true
      auto_upgrade = true
    }
  }

  enable_vertical_pod_autoscaling = true
  node_count                      = "0"
  # Additional GKE security values
  enable_private_nodes               = true
  disable_public_endpoint            = false
  enable_shielded_nodes              = true
  enable_binary_authorization        = false
  enable_workload_identity           = true
  enable_secrets_database_encryption = false
  # Annotations / labels
  cluster_resource_labels             = {}
  cluster_service_account_name        = "${include.shared.inputs.prefix}-sa-${include.shared.inputs.glb_name}-gke"
  cluster_service_account_description = "${include.shared.inputs.prefix}-sa-${include.shared.inputs.glb_name}-gke GKE Cluster Service Account managed by Terraform"
  enable_dataplane_v2                 = true
  cluster_secondary_range_name        = dependency.gke-network.outputs.seconday_pods_name
  service_secondary_range_name        = dependency.gke-network.outputs.seconday_services_name
  labels = {
    private-pools = "true"
  }
  #Additional nodepool
  enable_gateway_api       = true
  access_config_dns_access = true
  master_authorized_networks_config = [{
    cidr_blocks = [{
      cidr_block   = "0.0.0.0/0"
      display_name = "allow-master"
    }],
  }]
  node_pools = {
    main = {
      name = "main"
      nodepool_locations = [
        "${include.shared.inputs.region}-a",
        "${include.shared.inputs.region}-b",
        "${include.shared.inputs.region}-c",
      ]
      max_pods_per_node = 60
      nodepool_config = {
        autoscaling = {
          use_total_nodes = true
          min_node_count  = 0
          max_node_count  = 5
        }
        management = {
          auto_repair  = true
          auto_upgrade = true
        }
        labels = {
        }
      }
      nodepool_machine_type = "n2d-standard-2"
      disk_size_gb          = "30"
      disk_type             = "pd-balanced"
      nodepool_preemptible  = false
      nodepool_spot         = true
    },
  }
  maintenance_start_time = "04:00"
  oauth_scopes = [
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/cloud_debugger",
    "https://www.googleapis.com/auth/devstorage.read_write",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring",
    "https://www.googleapis.com/auth/service.management.readonly",
    "https://www.googleapis.com/auth/servicecontrol",
    "https://www.googleapis.com/auth/trace.append",

  ]
  service_account_roles = [
    "roles/storage.objectViewer",
    "roles/storage.objectCreator",
    "roles/storage.objectAdmin",
    "roles/cloudtrace.agent",
    "roles/artifactregistry.reader",
    "roles/cloudkms.cryptoKeyDecrypter",
    "roles/container.defaultNodeServiceAccount",
    "roles/cloudkms.cryptoKeyEncrypter"
  ]
}