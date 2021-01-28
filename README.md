# Cloud Migration with Network Automation & Service Mesh

## Pre-requisites

- [Consul](https://www.consul.io/downloads) v1.9+
- [Terraform](https://www.terraform.io/downloads.html) v0.14+
- [Consul Terraform Sync](https://github.com/hashicorp/consul-terraform-sync)

Check out the [AWS ALB Listener Rule](https://registry.terraform.io/modules/joatmon08/listener-rule/aws/latest) Terraform module, which is use by Consul Terraform Sync configuration.

## Usage

1. Add `cloud`, `datacenter`, and `cloud-deployments` as Terraform working
directories.

1. Change directory into `datacenter`.
   ```shell
   cd datacenter
   ```
1. Get the Terraform outputs, including the load balancer, target groups, and VPC ID.
   Copy the values, you will need them for `canary/datacenter.module.tfvars`.
   ```shell
   terraform output
   ```

1. Go into `canary`.
   ```shell
   cd canary
   ```

1. Copy `datacenter.module.tfvars.example` to `datacenter.module.tfvars`.
   ```shell
   cp datacenter.module.tfvars.example datacenter.module.tfvars
   ```

1. Paste the Terraform outputs, including load balancer, target groups, and VPC ID.

1. Copy `credentials.example` to `credentials`.
   ```shell
   cp credentials.example credentials
   ```

1. In `credentials`, add the AWS secrets and role assumption information.

1. Deploy Consul Terraform Sync to Kubernetes.
   ```shell
   terraform apply -var-file=credentials
   ```

## Caveats

- In this demo, the "cloud" application is hosted on Kubernetes (for ease of deployment).

- The ALB mimics a datacenter load balancer.

- The configuration peers two VPCs in two different regions.

- You would ideally configure your Kubernetes pod with an AWS IAM role
  for configuring a load balancer. To abstract away as many AWS constructs as possible,
  this demo passes the credentials to CTS directly to mimic the passing of any
  provider credentials.

- Consul Terraform Sync is deployed to Kubernetes so that the daemon continuously
  runs. It uses a Docker image built by `canary/Dockerfile`.