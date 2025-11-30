
remote_state {
  disable_dependency_optimization = true
  backend                         = "gcs"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }

  config = {
    project  = "shared-terraform-seed-[random_number]"
    location = "europe-west4"
    bucket   = "shared-terraform-seed-tfstate-[random_number]"
    prefix   = "${path_relative_to_include()}/terraform.tfstate"
  }
}

locals {
  organization_id                     = ""
  billing_account                     = ""
  quota_project                       = "shared-terraform-seed-[random_number]"
  organization_domain                 = ""
  region                              = "europe-west4"
  project_prefix                      = ""
  default_budget_notification_project = "shared-terraform-seed-[random_number]"
  prefix                              = "gc-"
  region_trigram                      = "euw4"
  client_name                         = "cst"
}