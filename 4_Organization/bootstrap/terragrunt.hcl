# Terragrunt configuration for the bootstrap module

remote_state {
 backend = "local"
 config = {
   path = "${path_relative_to_include()}/terraform.tfstate"
 }
 generate = {
   path      = "backend.tf"
   if_exists = "overwrite"
 }
}

# remote_state {
#   disable_dependency_optimization = true
#   backend                         = "gcs"
#   generate = {
#     path      = "backend.tf"
#     if_exists = "overwrite"
#   }

#   config = {
#     project  = "<seed project id>"
#     location = "europe-west4"
#     bucket   = "<seed project bucket name>"
#     prefix   = "bootstrap/terraform.tfstate"
#   }
# }

terraform {
  source = "github.com/terasky-int/training-modules.git//modules/bootstrap?ref=v0.0.1"
}

# Inputs for the bootstrap module
inputs = {
  # Required variables
  org_id          = "111111111111"         # Replace with your actual GCP Organization ID
  billing_account = "111111-111111-111111" # Replace with your actual billing account ID

  # Groups configuration
  groups = {
    create_required_groups = false # Set to true if you want to create groups automatically
    create_optional_groups = false # Set to true if you want to create optional groups
    billing_project        = null  # Provide a billing project ID if creating groups
    required_groups = {
      group_org_admins     = "gcp-organization-admins@example.com" # Replace with actual group email
      # group_billing_admins = "gcp-billing-admins@example.com"      # Replace with actual group email
    }
  }

  # Optional variables with default values (modify as needed)
  default_region                   = "europe-west3"
  parent_folder                    = "" # Set if deploying under a folder instead of org root
  org_policy_admin_role            = false
  project_prefix                   = "shared-terraform"
  folder_prefix                    = ""
  bucket_prefix                    = ""
  bootstrap_folder_name            = "Bootstrap" # Custom name for bootstrap folder
  bucket_force_destroy             = false
  bucket_tfstate_kms_force_destroy = false
  project_deletion_policy          = "PREVENT"
  folder_deletion_protection       = true

  # Additional project creators (if needed)
  org_project_creators = ["group:terasky-baltic-engineers@example.com","user:aivaras.s@terasky.com"] # e.g. ["group:gcp-project-creators@example.com"]
}