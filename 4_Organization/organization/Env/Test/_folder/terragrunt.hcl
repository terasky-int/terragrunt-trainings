terraform {
  source = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/folder?ref=v35.0.0"
}

include "shared" {
  path   = find_in_parent_folders()
  expose = true
}

dependency "parent" {
  config_path = "../../_folder"
}

inputs = {
  name                  = basename(dirname(get_terragrunt_dir()))
  parent                = dependency.parent.outputs.id
  iam                   = {}
  iam_bindings_additive = {}
  org_policies          = {}
  tag_bindings          = {}
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt" # Important: Terragrunt will manage this file
  contents  = <<EOF
provider "google" {
  project               = "${include.shared.locals.quota_project}"
  billing_project       = "${include.shared.locals.quota_project}"
  user_project_override = true
  region                = "${include.shared.locals.region}"
}
EOF
}