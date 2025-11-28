#terraform {
#  source = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/organization?ref=v40.2.0"
# }

# Include common configuration
#include "shared" {
#  path   = find_in_parent_folders()
#  expose = true
#}

#dependencies {
#  paths = [
#    "../_org" 
#  ]
#}

# Create a centralized log sink for the organization
#locals {
#    organization_id = "organizations/${include.shared.locals.organization_id}"
#}

# Inputs to pass to the Terraform module
#inputs = {

#parent = local.organization_id

#  organization_id = local.organization_id

#  logging_sinks = {
# This is a unique, descriptive name for your sink resource.
#    central-log-export = {
# 👇 This is the most critical part.
# It specifies the Cloud Logging bucket in your central logging project.
# Replace 'your-logging-project-id' with the actual project ID.
# '_Default' is the standard log bucket available in every project.
#      destination = "projects/'your-logging-project-id'/locations/global/buckets/_Default"

# The destination type is a logging bucket.
#      type = "logging"

# ✅ This ensures the sink captures logs from all child projects and folders.
#      include_children = true

# Optional: A filter to select which logs to route.
# If you omit the filter, ALL logs will be routed.
# Example: 'logName:"cloudaudit.googleapis.com"' to only send audit logs.
#      filter = ""

# Optional: A description for the sink.
#      description = "Organization-level sink to route all logs to the central logging project."

# Let the module manage IAM permissions for the sink's service account.
#      iam = true
#    }
#  }
#}  