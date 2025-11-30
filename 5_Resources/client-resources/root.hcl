remote_state {
  disable_dependency_optimization = true
  backend                         = "gcs"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }

  config = {
    bucket   = "gc-prj-cst-prod-demo-seed-s8y7"
    prefix   = "${path_relative_to_include()}/terraform.tfstate"
    project  = "gc-prj-cst-prod-demo"
    location = "europe-west4"
  }
}

locals {
  default_yaml_path = find_in_parent_folders("empty.yaml")
  common_inputs = merge(
    yamldecode(
      file("${find_in_parent_folders("defaults.yaml", local.default_yaml_path)}"),
    ),
    yamldecode(
      file("${find_in_parent_folders("env.yaml", local.default_yaml_path)}"),
    ),
  )
}

inputs = merge(
  local.common_inputs,
  {
    prefix             = "gc"
    glb_name           = "global-${local.common_inputs.client_name}-${local.common_inputs.env}"
    glb_name_region    = "${local.common_inputs.region_trigram}-${local.common_inputs.client_name}-${local.common_inputs.env}"
    vpc_name           = basename(local.common_inputs.vpc)
    subnet_name        = basename(local.common_inputs.subnet)
    subnet_name_short  = trimprefix(local.common_inputs.subnet, "https://www.googleapis.com/compute/v1/")
    shared_vpc_project = element(split("/", local.common_inputs.subnet), 6)
  }
)
