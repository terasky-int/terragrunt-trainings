
remote_state {
  disable_dependency_optimization = true
  backend                         = "gcs"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }

  config = {
    project  = "shared-terraform-seed-1f89"
    location = "europe-west4"
    bucket   = "shared-terraform-seed-tfstate-165c"
    prefix   = "${path_relative_to_include()}/terraform.tfstate"
  }
}

locals {
  organization_id                     = "973052204652"
  billing_account                     = "01CD22-389E8C-D21594"
  quota_project                       = "shared-terraform-seed-1f89"
  organization_domain                 = "gcp.tf.terasky.lt"
  region                              = "europe-west4"
  project_prefix                      = ""
  default_budget_notification_project = "shared-terraform-seed-1f89"

  prefix = "gc-"
  region_trigram = "euw4"
  client_name = "cst"
  env = "prod"
}