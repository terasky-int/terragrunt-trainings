include "shared" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "github.com/terasky-int/training-modules.git//modules/project"
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
    "logging.googleapis.com",
    "secretmanager.googleapis.com",
    "container.googleapis.com"

  ]
  iam                   = {}
  iam_bindings_additive = {}
  org_policies          = {}
  tag_bindings          = {}
  labels = {
    environment = "infra",
    service     = "networking",
    owner       = "vssa_admins"
  }
}