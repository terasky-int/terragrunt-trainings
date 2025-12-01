
terraform {
  source = "github.com/terasky-int/training-modules.git//modules/cloudsql-instance"
}

include "shared" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

inputs = {
  name             = "${include.shared.inputs.prefix}-sql-${include.shared.inputs.glb_name}"
  database_version = "POSTGRES_17"
  network          = "${include.shared.inputs.vpc}"
  psc_vpc_name = include.shared.inputs.vpc_name
  psc_subnet_name =  include.shared.inputs.subnet_name
  tier             = "db-custom-2-4096"
  flags = {
    "cloudsql.iam_authentication" = "on"
  }
  databases = [""]
  users = {
    web-user = {
      password     = null
      access_to_db = [""]
    }
  }
  insights_configuration = {
    enabled                 = true
    query_plans_per_minute  = 5
    query_string_length     = 1024
    record_application_tags = false
    record_client_address   = false
  }
  enable_private_path_for_google_cloud_services = true
  deletion_protection                           = true
  backup_configuration = {
    enabled                        = false
    binary_log_enabled             = true
    start_time                     = "23:00"
    location                       = "${include.shared.inputs.prefix}"
    point_in_time_recovery_enabled = true
    log_retention_days             = 7
    retention_count                = 7
  }
}