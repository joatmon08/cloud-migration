log_level = "INFO"

port = 8558

syslog {
  enabled = false
}

buffer_period {
  enabled = true
  min     = "20s"
  max     = "30s"
}

consul {
  address = "ab49b822e3f5d46f4957a01dbe376bf1-1851028653.us-west-2.elb.amazonaws.com"
}

driver "terraform" {
  log         = true
  persist_log = true
  version     = "1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.55"
    }
  }
  backend "consul" {
    gzip = false
  }
}

terraform_provider "aws" {
  region     = "us-east-1"
  access_key = "{{ env \"AWS_ACCESS_KEY_ID\" }}"
  secret_key = "{{ env \"AWS_SECRET_ACCESS_KEY\" }}"
  token      = "{{ env \"AWS_SESSION_TOKEN\" }}"
}

service {
  name        = "my-application"
  datacenter  = "cloud"
  description = "all instances of the service my-application in datacenter cloud"
  cts_user_defined_meta = {
    host = "my-application.my-company.net"
  }
}

task {
  name        = "canary"
  description = "send canary traffic to my-application in datacenter or ingress gateway in cloud"
  providers   = ["aws"]
  services    = ["ingress-gateway", "my-application"]
  source      = "joatmon08/listenerrule-nia/aws"
  version     = "0.3.0"
  variable_files = [
    "/Users/rosemarywang/demos/cloud-migration/consul_terraform_sync/datacenter.module.tfvars",
    "/Users/rosemarywang/demos/cloud-migration/consul_terraform_sync/service.tfvars"
  ]
}
