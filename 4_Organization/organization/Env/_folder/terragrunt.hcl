include "shared" {
  path   = find_in_parent_folders()
  expose = true
}


terraform {
  source = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/folder?ref=v35.0.0"
}

dependencies {
  paths = ["../../_org"]
}

locals {

  #  gcp_groups_roles = {
  #
  #    "gcp-data-engineering-editor" = [
  #      "roles/editor"                    
  #    ]
  #  }
}

inputs = {
  name   = basename(dirname(get_terragrunt_dir()))
  parent = "organizations/${include.shared.locals.organization_id}"
  # Convert groups/roles mapping to Fabric organization module IAM format
  iam                   = {}
  iam_bindings_additive = {}
  org_policies          = {}
  tag_bindings          = {}
}

#inputs = {
#  name                  = basename(dirname(get_terragrunt_dir()))
#  parent                = "organizations/${include.shared.locals.organization_id}"
#    # Convert groups/roles mapping to Fabric organization module IAM format
#  iam = {
#    for role in distinct(flatten(values(local.gcp_groups_roles))) : role => [
#      for group_name, roles in local.gcp_groups_roles :
#      "group:${group_name}@${include.shared.locals.organization_domain}"
#      if contains(roles, role)
#    ]
#  }
#  iam_bindings_additive = {
#    for binding in flatten([
#      for group, roles in local.gcp_groups_roles : [
#        for role in roles : {
#          key   = "${group}_${replace(role, "/[^a-zA-Z0-9]/", "_")}"
#          group = group
#          role  = role
#        }
#      ]
#      ]) : binding.key => {
#      member = "group:${binding.group}@${include.shared.locals.organization_domain}" # Adjust domain as needed
#      role   = binding.role
#    }
#  }
#  org_policies          = {}
#  tag_bindings          = {}
#}