include "shared" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "https://github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/iam-service-account?ref=master"
}

inputs = {

  name         = "sa-${include.shared.inputs.glb_name}"
  display_name = "sa-${include.shared.inputs.glb_name}"
  description  = ""

  iam_project_roles = {
    "${include.shared.inputs.project_id}" = [
      "roles/logging.logWriter",
      "roles/monitoring.metricWriter",
    ]
  }
}