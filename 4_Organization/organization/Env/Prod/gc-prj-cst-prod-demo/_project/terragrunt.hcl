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
    "logging.googleapis.com",
    "secretmanager.googleapis.com",
    "run.googleapis.com",
    "container.googleapis.com"

  ]
  iam                   = {}
  iam_bindings_additive = {}
  org_policies          = {
    "run.managed.requireInvokerIam"                          = { rules = [{ enforce = false }] }  # Requires IAM for Cloud Run invoker role
    "iam.allowedPolicyMemberDomains" = { # Requested entity already exists
      rules = [{
        allow_all = "TRUE"
      }]
    }
  }
  tag_bindings          = {}
  labels = {
    environment = "prod",
    service = "future-web",
    owner = "vssa_admins"
    }
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