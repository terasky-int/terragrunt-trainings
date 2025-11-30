include "shared" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "git::https://github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/cloud-run-v2?ref=master"
}

inputs = {
  name       = "${include.shared.inputs.prefix}-run-${include.shared.inputs.glb_name}-hello"

  containers = {
    hello = {
      image = "crccheck/hello-world"

      resources = { 
        limits = {
          cpu              = "1000m"
          memory           = "1Gi"
        }
      }

      # Optional: Ports
      ports = {
        default = {
          container_port = 8000
        }
      }
      

      env = {
        ENV_VAR_NAME = "value"
      }
    }
  }

  service_account_config = {
    create = true
    display_name = "${include.shared.inputs.prefix}-sa-${include.shared.inputs.glb_name}-run-helloworld"
  }
  # ingress = "INGRESS_TRAFFIC_ALL"


  revision = {
    vpc_access = {
      egress = "ALL_TRAFFIC"
      subnet = include.shared.inputs.subnet_name_short
    }
  }
  iam = {
    "roles/run.invoker" = ["allUsers"]
  }
  service_config = {
    gen2_execution_environment = true
    max_instance_count         = 20
    min_instance_count = 0
  }
  deletion_protection = false
}