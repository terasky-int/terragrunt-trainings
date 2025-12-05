module "bucket" {
  source = ".\\bucket_module"
  project = var.project
}

data "google_project" "project" {
  project_id = var.project
}

module "service-account-orgin" {
  source                 = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/iam-service-account?ref=v39.2.0"
  project_id             = var.project
  name                   = var.sa_name
  project_number         = data.google_project.project.number
  service_account_create = true
  iam_project_roles = {
    (var.project) = [
      "roles/storage.admin"
    ]
  }
  create_ignore_already_exists = true
  display_name                 = var.sa_name
}

resource "google_storage_hmac_key" "hmac_key" {
  project               = var.project
  service_account_email = module.service-account-orgin.email
}

