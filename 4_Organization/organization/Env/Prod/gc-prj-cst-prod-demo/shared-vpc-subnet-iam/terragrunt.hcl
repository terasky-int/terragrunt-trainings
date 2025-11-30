terraform {
  source = "github.com/terasky-int/tsb-tf-modules.git//checked-modules/subnet-policy"
}

include "shared" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "project" {
  config_path = "../_project"
  mock_outputs = {
    project_id = "12345678910"
  }
}

dependency "network_project" {
  config_path = "../../../../Infra/gc-prj-cst-infra-networking/_project"
  mock_outputs = {
    project_id = "12345678910"
  }
}

dependency "shared_vpc" {
  config_path = "../../../../Infra/gc-prj-cpva-infra-networking/shared-vpc"
}

locals {
  folder = "infra"
  env    = "prod"
}

inputs = {
  host_project     = dependency.network_project.outputs.project_id
  region           = include.shared.locals.region
  service_projects = [dependency.project.outputs.project_id]
  project          = dependency.project.outputs.project_id

  members_by_subnetwork_and_role = {
    "compute-engine-default-service-account" = {
      subnetwork = "${include.shared.locals.prefix}sub-${include.shared.locals.region_trigram}-${include.shared.locals.client_name}-${local.folder}-${local.env}-01"
      region     = include.shared.locals.region
      role       = "roles/compute.networkUser"
      member     = "serviceAccount:${dependency.project.outputs.number}-compute@developer.gserviceaccount.com"
    },
    "cloud-run-service-account" = {
      subnetwork = "${include.shared.locals.prefix}sub-${include.shared.locals.region_trigram}-${include.shared.locals.client_name}-${local.folder}-${local.env}-01"
      region     = include.shared.locals.region
      role       = "roles/compute.networkUser"
      member     = "serviceAccount:service-${dependency.project.outputs.number}@serverless-robot-prod.iam.gserviceaccount.com"
    },
    "gke-service-account" = {
      subnetwork = "${include.shared.locals.prefix}sub-${include.shared.locals.region_trigram}-${include.shared.locals.client_name}-${local.folder}-${local.env}-01"
      region     = include.shared.locals.region
      role       = "roles/compute.networkUser"
      member     = "serviceAccount:${dependency.project.outputs.number}@cloudservices.gserviceaccount.com"
    }
  }
}