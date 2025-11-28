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