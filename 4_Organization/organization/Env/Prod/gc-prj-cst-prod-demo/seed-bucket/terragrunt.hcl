terraform {
  source = "github.com/terasky-int/training-modules.git//modules/bucket"
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

inputs = {
  project = dependency.project.outputs.project_id
  region = include.shared.locals.region
  bucket_name = "gc-prj-cst-prod-demo-seed-s8y7"
  bucket_location = include.shared.locals.region
}