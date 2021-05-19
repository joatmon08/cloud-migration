# Cloud Migration with Network Automation & Service Mesh

## Pre-requisites

- [Consul](https://www.consul.io/downloads) v1.9+
- [Terraform](https://www.terraform.io/downloads.html) v0.14+
- [Consul Terraform Sync](https://github.com/hashicorp/consul-terraform-sync)

Check out the [AWS ALB Listener Rule](https://registry.terraform.io/modules/joatmon08/listener-rule/aws/latest) Terraform module, which is use by Consul Terraform Sync configuration.

## Usage

### Set up datacenter and cloud deployments

1. Go into `datacenter` and run `terraform apply`.

1. Go into `cloud` and run `terraform apply`.

1. Go into `datacenter` and update the variable for `enable_peering = true`.
   Run `terraform apply` to accept the peering connection from cloud.

### Deploy Consul and example workload

1. Go to the top-level of this repository.
   ```shell
   cd ..
   ```

1. Set the `kubeconfig` to the AWS EKS cluster in cloud. Make sure
   you are logged into AWS.
   ```shell
   make kubeconfig
   ```

1. Change directory into `cloud-deployments`.
   ```shell
   cd cloud-deployments
   ```

1. Copy `credentials.example` to `credentials`.
   ```shell
   cp credentials.example credentials
   ```

1. In `credentials`, add the AWS role ARN. The Kubernetes context for Terraform
   will use the current context you set as part of the previous steps.


1. Source the `credentials` file to set the variables for Terraform.
   ```shell
   source credentials
   ```

1. Deploy Consul Helm chart, ingress gateway configuration, and application to Kubernetes.
   ```shell
   terraform apply
   ```

### Run Consul Terraform Sync to update ALB based on Consul service

1. Go to the top-level of this repository.
   ```shell
   cd ..
   ```

1. Generate variables for Consul Terraform Sync to use in its module and save
   them in `canary/datacenter.modules.tfvars`. This includes an ALB, listener rule,
   and target group created by the `datacenter` Terraform configuration. It also
   updates `config.local.hcl` with the Consul UI load balancer endpoint.
   ```shell
   make consul_terraform_sync_variables
   ```

1. Run Consul Terraform Sync.
   ```shell
   make consul_terraform_sync
   ```
## Test it out

1. Go to the top-level of this repository.
   ```shell
   cd ..
   ```

1. To verify everything is working, get the load balancer's DNS and issue
   an HTTP GET request with the `Host` header set to `my-application.my-company.net`.
   ```shell
   make test
   ```

## Clean up

1. Clean up CTS and the Consul deployment to Kubernetes.
   ```shell
   make clean
   ```

1. Go into `cloud`.

1. Run a `terraform destroy` for `cloud`.

1. Go into `datacenter` and update the variable for `enable_peering = false`.

1. Run `terraform destroy` for `datacenter`.

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