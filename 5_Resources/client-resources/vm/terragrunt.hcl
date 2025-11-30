include "shared" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "git::https://github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/compute-vm?ref=v34.0.0"
}

dependency "service_account" {
  config_path = "../service-account"
  mock_outputs = {
    email = "mock-sa@my-project-id.iam.gserviceaccount.com"
  }
}

inputs = {
  name       = "${include.shared.inputs.prefix}-vm-${include.shared.inputs.glb_name}"
  zone  = "${include.shared.inputs.region}-a"
  instance_type = "e2-medium"
  network_interfaces = [{
    network    = "${include.shared.inputs.vpc}" # Or reference a custom VPC: "projects/my-project/global/networks/my-vpc"
    subnetwork = "${include.shared.inputs.subnet}" # Or reference a custom subnet
    nat        = false     # Set to true to assign an external IP
  }]

  # Boot Disk Configuration
  boot_disk = {
      initialize_params = {
    image = "projects/debian-cloud/global/images/family/debian-11"
    size  = 20
    type  = "pd-balanced"
      }
  }

  # Attach the custom Service Account
  service_account = {
    email  = dependency.service_account.outputs.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
  shielded_config =  {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }
  # Optional: Add tags
  tags = ["ssh-allowed", "http-server"]
}