
terraform {
  source = "github.com/terasky-int/training-modules.git//checked-modules/shared-vpc"
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

locals {
  folder = "infra"
  prefix = "gc-"
  region_trigram = "euw4"
  client_name = "cst"
  env = "prod"
  glb_name = "global-${local.client_name}-${local.folder}-${local.env}"
  glb_name_region = "${local.region_trigram}-${local.client_name}-${local.folder}-${local.env}"
  vpc_name = "${local.prefix}vpc-${local.glb_name}-01"
  #shared_vpc_service_projects = [""]
}

inputs = {
  vpc_name = local.vpc_name
  #shared_vpc_service_projects = local.shared_vpc_service_projects
  project = dependency.project.outputs.project_id
  region = include.shared.locals.region
  create_googleapis_routes = {}
  subnets = [
    {
      name          = "${local.prefix}sub-${local.glb_name_region}-01"
      ip_cidr_range = "10.207.255.128/27"
      region        = include.shared.locals.region # europe-west3
      description   = ""
    },
  ]
  shared_vpc_host = true
  external_addresses = {
    "${local.prefix}nat-eip-${local.glb_name_region}-01" = include.shared.locals.region
  }

  cloud_nat = [
    {
      name                                = "${local.prefix}nat-${local.glb_name_region}-01"
      region                              = include.shared.locals.region
      external_address_name               = "${local.prefix}nat-eip-${local.glb_name_region}-01"
      router_create                       = true
      router_name                         = "${local.prefix}rtr-eip-${local.glb_name_region}-01"
      router_network                      = local.vpc_name
      router_bgp_asn                      = 65000
      router_bgp_advertise_mode           = "DEFAULT"
      subnetworks                         = []
      enable_endpoint_independent_mapping = false
      config_min_ports_per_vm             = "1024"
      subnetworks                         = []
    }
  ]
  ingress_rules = {
    # implicit allow action
    # allow-websocket = {
    #   description = "Allow ingress websocket from allow-websocket tags"
    #   targets     = ["allow-websocket"]
    #   source_ranges = ["0.0.0.0/0"]
    #   rules       = [{ protocol = "tcp", ports = [8433] }]
    # }
    # default-allow-http = {
    #   description   = "Allow ingress http from a http-server tag."
    #   targets       = ["http-server"]
    #   source_ranges = ["0.0.0.0/0"]
    #   rules       = [{ protocol = "tcp", ports = [80] }]
    # }
    # default-allow-https = {
    #   description   = "Allow ingress https from a https-server tag."
    #   targets       = ["https-server"]
    #   source_ranges = ["0.0.0.0/0"]
    #   rules       = [{ protocol = "tcp", ports = [443] }]
    # }
    # serverless-to-vpc-connector = {
    #   description   = "Allow ingress serverless to vpc connector."
    #   targets       = ["vpc-connector"]
    #   source_ranges = ["107.178.230.64/26","35.199.224.0/19"]
    #   rules       = [{ protocol = "tcp", ports = [667] },{protocol = "udp", ports = [665,666]},{ protocol = "icmp"}]
    # }
    # allow-iap = {
    #   description = "allow iap access"
    #   source_ranges = ["35.235.240.0/20"]
    #   rules       = [{ protocol = "tcp", ports = [22] }]
    # }
    # allow-ssh = {
    #   description   = ""
    #   targets       = ["ssh"]
    #   source_ranges = ["0.0.0.0/0"]
    #   rules       = [{ protocol = "tcp", ports = [22] }]      
    # }
    # vpc-connector-health-checks = {
    #   description   = "Allow ingress health check serverless to vpc connector."
    #   targets       = ["vpc-connector"]
    #   source_ranges = ["130.211.0.0/22","35.191.0.0/16","108.170.220.0/23"]
    #   rules       = [{ protocol = "tcp", ports = [667] }]
    # }
    # vpc-connector-requests = {
    #   description   = "Allow requests from connectors."
    #   targets       = ["vpc-connector"]
    #   source_ranges = ["130.211.0.0/22","35.191.0.0/16","108.170.220.0/23"]
    #   rules       = [{ protocol = "tcp" },{ protocol = "udp"},{ protocol = "icmp"},]
    # }
    # fw-allow-health-checks = {
    #   description   = ""
    #   targets       = ["private"]
    #   source_ranges = ["35.191.0.0/16","130.211.0.0/22"]
    #   rules       = [{ protocol = "all" }]     
    # }
  }
  egress_rules = {
    # vpc-connector-to-serverless = {
    #   description   = "Allow egress serverless to vpc connector."
    #   targets       = ["vpc-connector"]
    #   source_ranges = ["107.178.230.64/26","35.199.224.0/19"]
    #   rules       = [{ protocol = "tcp", ports = [667] },{protocol = "udp", ports = [665,666]},{ protocol = "icmp"}]
    # }    
  }
  default_rules_config = {
    disabled = true
  }
}
