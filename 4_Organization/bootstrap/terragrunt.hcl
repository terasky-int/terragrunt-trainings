# Terragrunt configuration for the bootstrap module

#remote_state {
#backend = "local"
# config = {
#   path = "${path_relative_to_include()}/terraform.tfstate"
# }
#   generate = {
#     path      = "backend.tf"
#     if_exists = "overwrite"
#   }
#}

remote_state {
   disable_dependency_optimization = true
   backend                         = "gcs"
   generate = {
     path      = "backend.tf"
     if_exists = "overwrite"
   }

   config = {
     project  = "shared-terraform-seed-1f89"
     location = "europe-west4"
     bucket   = "shared-terraform-seed-tfstate-165c"
     prefix   = "bootstrap/terraform.tfstate"
   }
}

terraform {
  source = "github.com/terasky-int/training-modules.git//modules/bootstrap"#?ref=v0.0.1&depth=1"
}

# Inputs for the bootstrap module
inputs = {
  # Required variables
  org_id          = "973052204652"         # Replace with your actual GCP Organization ID
  billing_account = "01CD22-389E8C-D21594" # Replace with your actual billing account ID

  # Groups configuration
  groups = {
    create_required_groups = false # Set to true if you want to create groups automatically
    create_optional_groups = false # Set to true if you want to create optional groups
    billing_project        = null  # Provide a billing project ID if creating groups
    required_groups = {
      group_org_admins     = "gcp-organization-admins@gcp.tf.terasky.lt" # Replace with actual group email
    #  group_billing_admins = "gcp-billing-admins@example.com"      # Replace with actual group email
    }
  }

  # Optional variables with default values (modify as needed)
  default_region                   = "europe-west3"
  parent_folder                    = "" # Set if deploying under a folder instead of org root
  org_policy_admin_role            = false
  project_prefix                   = "shared-terraform"
  folder_prefix                    = ""
  bucket_prefix                    = ""
  bootstrap_folder_name            = "Bootstraps" # Custom name for bootstrap folder
  bucket_force_destroy             = false
  bucket_tfstate_kms_force_destroy = false
  project_deletion_policy          = "PREVENT"
  folder_deletion_protection       = true

  # Additional project creators (if needed)
  org_project_creators = ["user:aivaras.s@terasky.com","group:gcp-organization-admins@gcp.tf.terasky.lt"] # e.g. ["group:gcp-project-creators@example.com"]
}