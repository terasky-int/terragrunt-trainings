# Local values for groups and roles mapping
locals {

  # Base groups and their roles mapping
  gcp_groups_roles = {

    "gcp-sre-org-admins" = [
      "roles/billing.user",                      # Billing Account User
      "roles/compute.xpnAdmin",                  # Compute Shared VPC Admin
      "roles/resourcemanager.folderAdmin",       # Folder Admin
      "roles/iam.denyAdmin",
      "roles/resourcemanager.organizationAdmin", # Organization Administrator
      "roles/orgpolicy.policyAdmin",             # Organization Policy Administrator
      "roles/iam.organizationRoleAdmin",         # Organization Role Administrator
      "roles/owner",                             # Owner
      "roles/resourcemanager.projectCreator",    # Project Creator
      "roles/securitycenter.admin",              # Security Center Admin
      "roles/cloudsupport.admin"                 # Support Account Administrator
    ]

#    "gcp-customer-org-all-customer_admins" = [
#      #"roles/billing.user",                      # Billing Account User will be granted on the Billing Account itself which belongs to the reseller
#      #"roles/billing.viewer",                    # Billing Account Viewer will be granted on the Billing Account itself which belongs to the reseller
#      "roles/compute.xpnAdmin",                  # Compute Shared VPC Admin
#      "roles/resourcemanager.folderAdmin",       # Folder Admin
#      "roles/resourcemanager.projectCreator",    # Project Creator
#      "roles/securitycenter.admin",              # Security Center Admin
#      "roles/cloudsupport.admin"                 # Support Account Administrator
#    ]

#    "gcp-customer-org-all-customer_viewers" = [
#      "roles/viewer"
#    ]

  }
  # Organization policies configuration
  org_policies = {
    # "compute.managed.blockPreviewFeatures"                     = { rules = [{ enforce = true }] } # Blocks use of preview features
    # "iam.automaticIamGrantsForDefaultServiceAccounts"          = { rules = [{ enforce = false }] } # Recommended: Set to 'false' to disable auto-granting editor role #Requested entity already exists
    # "cloudbuild.disableCreateDefaultServiceAccount"            = { rules = [{ enforce = true }] } # Disables auto-creation of default CB service account
    # "iam.managed.disableServiceAccountApiKeyCreation"          = { rules = [{ enforce = true }] } # Disables creating API keys for SAs
    # "iam.managed.disableServiceAccountKeyCreation"             = { rules = [{ enforce = true }] } # Disables creating external keys for SAs
    # "iam.managed.disableServiceAccountKeyUpload"               = { rules = [{ enforce = true }] } # Disables uploading public keys for SAs #Requested entity already exists
    # "storage.uniformBucketLevelAccess"                         = { rules = [{ enforce = true }] } # Enforces uniform bucket-level access for all new buckets #Requested entity already exists 
    # "compute.setNewProjectDefaultToZonalDNSOnly"               = { rules = [{ enforce = true }] } # Sets new projects to use zonal DNS #Requested entity already exists
    "storage.publicAccessPrevention" = { rules = [{ enforce = true }] } # Enforces public access prevention on all buckets
    "gcp.detailedAuditLoggingMode"   = { rules = [{ enforce = true }] } # Enables detailed audit logging
    # "iam.managed.preventPrivilegedBasicRolesForDefaultServiceAccounts" = { rules = [{ enforce = true }] } # Prevents Owner/Editor/Viewer on default SAs
    "container.managed.enableNetworkPolicy"     = { rules = [{ enforce = true }] } # Enforces Network Policy in GKE clusters #Requested entity already exists
    #"container.managed.enablePrivateNodes"      = { rules = [{ enforce = true }] } # Enforces Private Nodes in GKE clusters
    "container.managed.enableSecretsEncryption" = { rules = [{ enforce = true }] } # Enforces app-layer secret encryption in GKE
    # "container.managed.enableWorkloadIdentityFederation"       = { rules = [{ enforce = true }] } # Enforces Workload Identity in GKE #Requested entity already exists 
    "run.managed.requireInvokerIam"                          = { rules = [{ enforce = true }] }  # Requires IAM for Cloud Run invoker role
    "compute.requireOsLogin"                                 = { rules = [{ enforce = true }] }  # Enforces OS Login for SSH access
    "sql.restrictPublicIp"                                   = { rules = [{ enforce = true }] }  # Restricts public IPs on Cloud SQL instances
    "ainotebooks.restrictPublicIp"                           = { rules = [{ enforce = true }] }  # Restricts public IPs on Vertex AI Notebooks
    "compute.requireShieldedVm"                              = { rules = [{ enforce = true }] }  # Requires new VMs to be Shielded VMs
    "compute.skipDefaultNetworkCreation"                     = { rules = [{ enforce = true }] }  # Skips creating the 'default' VPC network in new projects
    "cloudbuild.useComputeServiceAccount"                    = { rules = [{ enforce = false }] } # Do not allow to use Compute Engine SA for Cloud Build
    "cloudbuild.useBuildServiceAccount"                      = { rules = [{ enforce = false }] } # Do not allow to use Default Cloud Build SA
    "container.managed.disallowDefaultComputeServiceAccount" = { rules = [{ enforce = true }] }  # Do not allow using Default Compute SA as a node pool SA
    "pubsub.enforceInTransitRegions"                         = { rules = [{ enforce = true }] }  # Enforce in-transit regions for Pub/Sub
    # "container.managed.enableGoogleGroupsRBAC"                 = { rules = [{ enforce = true }] } # Require enabling Google Groups for RBAC in GKE #Requested entity already exists 
    # "container.managed.enableControlPlaneDNSOnlyAccess"        = { rules = [{ enforce = true }] } # Require using DNS-based endpoint in GKE #Requested entity already exists 

    # "compute.managed.restrictProtocolForwardingCreationForTypes" = { rules = [{ enforce = true }] }
    # Defines the list of service accounts allowed to have extended token lifetimes.
    #    "iam.allowServiceAccountCredentialLifetimeExtension" = {
    #      rules = [
    #        # OPTION A: To explicitly DENY all extensions (most common security posture)
    #        { deny = { all = true } },
    #
    #        # OPTION B: To ALLOW specific service accounts
    #        # { allow = { values = ["service-account-email@your-project.iam.gserviceaccount.com"] } }
    #      ]
    #    }
    # Allows export only to specific destinations (e.g., a vendor org).
    "resourcemanager.allowedExportDestinations" = {
      rules = [
        { deny = { all = true } },
        #  allow = { values = ["under:organizations/ORGANIZATION_ID"] } #deny
      ]
    }

    # Allows import only from specific sources.
    "resourcemanager.allowedImportSources" = {
      rules = [
        { deny = { all = true } },
        #  allow = { values = ["under:organizations/98271195640"] } # deny
      ]
    }

    # Allows export of Shared VPC to defined organizations.
    "resourcemanager.allowEnabledServicesForExport" = {
      rules = [
        { deny = { all = true } },
        #  allow = { values = ["under:organizations/98271195640"] } # deny
      ]
    }

    # Disable use of old runtimes in App Engine.
    "appengine.runtimeDeploymentExemption" = {
      rules = [
        { deny = { all = true } },
      ]
    }

    # Disable use of Shared reservations

    "compute.sharedReservationsOwnerProjects" = {
      rules = [
        { deny = { all = true } }
      ]
    }

    # Restricts identities to specific customer-owned domains.
    # "iam.allowedPolicyMemberDomains" = { # Requested entity already exists
    #   rules = [{
    #     allow = { values = ["C0123abcd"] } # Replace with your Cloud Identity Customer ID
    #   }]
    # }

    #Restricts which services can be enabled.
       "gcp.restrictServiceUsage" = {
         rules = [{
           allow = { values = [
             "dns.googleapis.com",
             "securitycenter.googleapis.com",
             "osconfig.googleapis.com",
             "run.googleapis.com",
             "container.googleapis.com",
             "sqladmin.googleapis.com",
             "servicedirectory.googleapis.com",
             "discoveryengine.googleapis.com",
             "storage.googleapis.com",
             "servicehealth.googleapis.com",
             "compute.googleapis.com",
             "connectors.googleapis.com",
             "secretmanager.googleapis.com",
             "accesscontextmanager.googleapis.com",
             "billingbudgets.googleapis.com",
             "vmmigration.googleapis.com"

           ] }
         }]
       }

    # # Restricts which physical locations can be used for resources.
    "gcp.resourceLocations" = {
      rules = [{
        allow = { values = [
          # "in:europe-locations", "in:us-locations" # Example group: allows all of Europe
          "in:europe-west3-locations", "in:europe-west4-locations"
        ] }
      }]
    }

    # Restricts creating external IP addresses for VMs.
    "compute.vmExternalIpAccess" = {
      rules = [{
        deny = { all = true } # Denies for all VMs. Use 'allow' to specify exceptions.
      }]
    }

    # Restricts VM images to trusted sources.
    #    "compute.trustedImageProjects" = {
    #      rules = [{
    #        allow = { values = [
    #          "projects/cos-cloud",
    #          "projects/rhel-cloud",
    #          "projects/suse-cloud",
    #          "projects/ubuntu-os-cloud",
    #          "projects/windows-cloud",
    #          # Add any custom image projects you have
    #        ] }
    #      }]
    #    }
  }

  # Custom roles configuration
  custom_roles = {
    # "customProjectViewer" = [
    #   "resourcemanager.projects.get",
    #   "resourcemanager.projects.list",
    #   "monitoring.timeSeries.list",
    #   "logging.logs.list"
    # ]
  }

  # Convert groups/roles mapping to Fabric organization module IAM format
  organization_iam = {
    for role in distinct(flatten(values(local.gcp_groups_roles))) : role => [
      for group_name, roles in local.gcp_groups_roles :
      "group:${group_name}@${include.shared.locals.organization_domain}"
      if contains(roles, role)
    ]
  }
  iam_bindings_additive = {
    for binding in flatten([
      for group, roles in local.gcp_groups_roles : [
        for role in roles : {
          key   = "${group}_${replace(role, "/[^a-zA-Z0-9]/", "_")}"
          group = group
          role  = role
        }
      ]
      ]) : binding.key => {
      member = "group:${binding.group}@${include.shared.locals.organization_domain}" # Adjust domain as needed
      role   = binding.role
    }
  }
  organization_id = "organizations/${include.shared.locals.organization_id}"

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

terraform {
  #  source = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/organization?ref=v40.2.0"
  source = "github.com/terasky-int/training-modules.git//modules/organization"
}

# Include common configuration
include "shared" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

# Inputs to pass to the Terraform module
inputs = {

  # IAM bindings using the converted format
  # iam = local.organization_iam
  organization_id = local.organization_id
  # Additional specific IAM bindings
  iam_bindings_additive = local.iam_bindings_additive
  #  deny_policies = local.deny_policies
  # Organization policies
  org_policies = local.org_policies

  #dynamic_custom_roles = local.dynamic_custom_roles
  # Custom roles
  custom_roles = local.custom_roles

  # Tags configuration (optional)
  tags = {
    #    environment = {
    #      description = "Environment designation"
    #      values = {
    #        development = {}
    #        staging     = {}
    #        production  = {}
    #      }
    #    }
  }

  # Firewall policies (optional)
  firewall_policies = {
  }
}