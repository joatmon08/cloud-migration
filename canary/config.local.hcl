log_level = "INFO"

port = 8558

syslog {
  enabled = false
}

buffer_period {
  enabled = true
  min     = "5s"
  max     = "20s"
}

consul {
  address = "127.0.0.1:8500"
}

driver "terraform" {
  log         = true
  persist_log = true

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.23"
    }
  }
  backend "consul" {
    gzip = false
  }
}

terraform_provider "aws" {
  region     = "us-east-2"
  access_key = "{{ env \"AWS_ACCESS_KEY_ID\" }}"
  secret_key = "{{ env \"AWS_SECRET_ACCESS_KEY\" }}"
  token      = "{{ env \"AWS_SESSION_TOKEN\" }}"
}

service {
  name        = "my-application"
  datacenter  = "cloud"
  description = "all instances of the service my-application in datacenter cloud"
  cts_user_defined_meta = {
    host   = "my-application.my-company.net"
  }
}

task {
  name        = "canary"
  description = "send canary traffic to my-application in datacenter or ingress gateway in cloud"
  providers   = ["aws"]
  services    = ["ingress-gateway", "my-application"]
  source      = "joatmon08/listenerrule-nia/aws"
  version     = "0.2.1"
  variable_files = [
    "/Users/rosemarywang/demos/cloud-migration/canary/datacenter.module.tfvars",
    "/Users/rosemarywang/demos/cloud-migration/canary/service.tfvars"
  ]
}
