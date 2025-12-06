include "shared" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}


terraform {
  source = "github.com/terasky-int/training-modules.git//modules/folder"
}

dependencies {
  paths = ["../../_org"]
}

locals {

}

inputs = {
  name                  = basename(dirname(get_terragrunt_dir()))
  parent                = "organizations/${include.shared.locals.organization_id}"
  iam                   = {}
  iam_bindings_additive = {}
  org_policies          = {}
  tag_bindings          = {}
}