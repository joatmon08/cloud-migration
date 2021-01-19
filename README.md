# Cloud Migration with Network Automation & Service Mesh

## Pre-requisites

- [Consul](https://www.consul.io/downloads) v1.9+
- [Terraform](https://www.terraform.io/downloads.html) v0.14+
- [Consul Terraform Sync](https://github.com/hashicorp/consul-terraform-sync) tech-preview2

Check out the [AWS ALB Listener Rule](https://registry.terraform.io/modules/joatmon08/listener-rule/aws/latest) Terraform module, which is use by Consul Terraform Sync configuration.

## Usage

1. Add `cloud`, `datacenter`, and `cloud-deployments` as Terraform working
directories.
1. Go into `canary` and run `consul-terraform-sync -config-dir .`.