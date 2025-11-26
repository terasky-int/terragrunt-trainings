terraform {
  source = "github.com/terasky-int/tsb-tf-modules.git//modules/billing-account"
}

# Include common configuration
include "shared" {
  path   = find_in_parent_folders()
  expose = true
}

dependency "Infra" {
  config_path = "../Infra/_folder"
}

dependency "Sandbox" {
  config_path = "../Sandbox/_folder"
}

dependency "Env" {
  config_path = "../Env/_folder"
}

dependencies {
  paths = [
    "../_org" 
  ]
}

inputs = {
  id = include.shared.locals.billing_account
  budget_notification_channels = {
    billing-admins = {
      project_id = include.shared.locals.default_budget_notification_project
      type       = "email"
      labels = {
        email_address = "billing@example.com"
      }
    }
  }

  budgets = {
    organization-month-current = {
      display_name = "Current month's spend of the organization"
      amount = {
        currency_code = "EUR"
        units = "1000"        
      }
      filter = {
        period = {
          calendar = "MONTH"
        }
        resource_ancestors = [dependency.Sandbox.outputs.id]
      }

      threshold_rules = [
        { percent = 1 },
        { percent = 0.9 },
        { percent = 0.8 },
        { percent = 0.7 },
        { percent = 0.6 }
      ]
      update_rules = {
        default = {
          disable_default_iam_recipients   = true
          monitoring_notification_channels = ["billing-admins"]
        }
      }
    }
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt" # Important: Terragrunt will manage this file
  contents  = <<EOF
provider "google" {
  project               = "${include.shared.locals.quota_project}"
  billing_project       = "${include.shared.locals.quota_project}"
  user_project_override = true
  region                = "${include.shared.locals.region}"
}
EOF
}