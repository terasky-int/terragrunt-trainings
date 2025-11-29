include "shared" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/project?ref=v40.2.0"
}

dependency "folder" {
  config_path = "../../_folder"
  mock_outputs = {
    id = "folders/12345678910"
  } 
}

inputs = {
  name            = "${basename(dirname(get_terragrunt_dir()))}"
  id              = "${basename(dirname(get_terragrunt_dir()))}"
  parent          = dependency.folder.outputs.id
  billing_account = include.shared.locals.billing_account
  services = [
    "compute.googleapis.com",
    "billingbudgets.googleapis.com",
    "orgpolicy.googleapis.com",
    "networkconnectivity.googleapis.com",
    "logging.googleapis.com"

  ]
  iam                   = {}
  iam_bindings_additive = {}
  org_policies          = {}
  tag_bindings          = {}
  labels = {
    environment = "prod",
    service = "demo",
    owner = "vssa_admins"
    }
}