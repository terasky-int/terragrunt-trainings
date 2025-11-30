terraform {
  source = "github.com/terasky-int/training-modules.git//modules/shared-vpc-self-link"
}

include "shared" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

inputs = {
  project = include.shared.inputs.shared_vpc_project
  network_name = include.shared.inputs.vpc_name
  subnet_name  = include.shared.inputs.subnet_name
}