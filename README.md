# Cloud Migration with Network Automation & Service Mesh

## Pre-requisites

- [Consul](https://www.consul.io/downloads) v1.9+
- [Terraform](https://www.terraform.io/downloads.html) v0.14+
- [Consul Terraform Sync](https://github.com/hashicorp/consul-terraform-sync)

Check out the [AWS ALB Listener Rule](https://registry.terraform.io/modules/joatmon08/listener-rule/aws/latest) Terraform module, which is use by Consul Terraform Sync configuration.

## Usage

1. Go into `datacenter` and run `terraform apply`.

1. Go into `cloud` and run `terraform apply`.

1. Go into `datacenter` and update the variable for `enable_peering = true`.
   Run `terraform apply` to accept the peering connection from cloud.

1. Set `kubectl` to the AWS EKS cluster in cloud.
   ```shell
   aws eks --region us-west-2 update-kubeconfig --name cloud
   ```

1. Change directory into `cloud-deployments`.
   ```shell
   cd cloud-deployments
   ```

1. Copy `credentials.example` to `credentials`.
   ```shell
   cp credentials.example credentials
   ```

1. In `credentials`, add the AWS role ARN and the Kubernetes context for EKS clusters.

1. Deploy Consul Helm chart, ingress gateway configuration, and application to Kubernetes.
   ```shell
   terraform apply -var-file=credentials
   ```

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

1. To verify everything is working, get the load balancer's DNS and issue
   an HTTP GET request with the `Host` header set to `my-application.my-company.net`.
   ```shell
   curl -H 'Host:my-application.my-company.net' my-application-1971614036.us-east-2.elb.amazonaws.com
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