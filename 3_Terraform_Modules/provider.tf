provider "google" {
  project = var.project
  region  = var.region
  batching {
    enable_batching = "false"
  }
}

terraform {
  required_version = ">= 1.4.4"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.82.0" # tftest
    }
  }
}
