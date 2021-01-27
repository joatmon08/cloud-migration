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
  address = "consul-consul-server:8500"
}

driver "terraform" {
  log         = true
  persist_log = true
  path = "/tmp"
  working_dir = "/tmp/sync-tasks"

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
  assume_role {
    role_arn     = "{{ env \"AWS_ROLE_ARN\" }}"
  }
}

service {
  name        = "my-application"
  datacenter  = "cloud"
  description = "all instances of the service my-application in datacenter cloud"
}

task {
  name           = "canary"
  description    = "send canary traffic to my-application in datacenter cloud"
  providers      = ["aws"]
  services       = ["my-application"]
  source         = "joatmon08/listener-rule/aws"
  version        = "0.1.3"
  variable_files = ["/opt/consul-terraform-sync/datacenter.module.tfvars"]
}
