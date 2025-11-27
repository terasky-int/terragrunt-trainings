provider "google" {
  project = var.project
  region  = var.region
  batching {
    enable_batching = "false"
  }
}

variable "project" {
  description = "The project ID to host the cluster in"
  type        = string
}

variable "region" {
  description = "The region"
  type        = string
}

variable "bucket_name" {
  description = "Name for GCS bucket"
  type        = string
}

variable "bucket_location" {
  description = "GCS bucket location"
  type        = string
}

resource "google_storage_bucket" "bucket" {
  name                        = var.bucket_name
  location                    = var.bucket_location
  project                     = var.project
  uniform_bucket_level_access = true
}

output "bucket_name" {
  value = trimprefix(google_storage_bucket.bucket.url, "gs://")
}