include "shared" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "git::https://github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/net-lb-app-ext?ref=master"
}

dependency "cloud-run" {
  config_path = "../cloud-run"
}

inputs = {
  name       = "${include.shared.inputs.prefix}-alb-${include.shared.inputs.glb_name}"
  backend_service_configs = {
    default = {
      backends = [
        { backend = "${include.shared.inputs.prefix}-neg-${include.shared.inputs.glb_name}" }
      ]
      health_checks = []
      port_name     = ""
    }
  }
  health_check_configs = {}
  neg_configs = {
    "${include.shared.inputs.prefix}-neg-${include.shared.inputs.glb_name}" = {
      cloudrun = {
        region = include.shared.inputs.region
        target_service = {
          name = dependency.cloud-run.outputs.service_name
        }
      }
    }
  }
}