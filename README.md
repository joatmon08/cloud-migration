# Cloud Migration with Network Automation & Service Mesh

## Pre-requisites

- [Consul](https://www.consul.io/downloads) v1.10+
- [Terraform](https://www.terraform.io/downloads.html) v1.0+
- [Terraform Cloud](https://app.terraform.io/signup/account?utm_source=terraform_io&utm_content=terraform_cloud_hero)
- [Consul Terraform Sync](https://github.com/hashicorp/consul-terraform-sync)

Check out the [AWS ALB Listener Rule](https://registry.terraform.io/modules/joatmon08/listener-rule/aws/latest)
Terraform module, which is use by Consul Terraform Sync configuration.

This repository uses Terraform Cloud to store infrastructure state.

To set it up:

1. Fork this repository.
1. Create 4 workspaces.
   1. `datacenter`
   1. `k8s-cloud`
   1. `consul`
   1. `application`
1. Connect the workspace with VCS workflow to your fork and set their working directories.
   1. `datacenter`: working directory is `datacenter`
   1. `k8s-cloud`: working directory is `cloud`
   1. `consul`: working directory is `consul`
   1. `application`: working directory is `application`
1. Add AWS credentials as sensitive environment variables to each workspace.
1. Define two variables in `datacenter`:
   1. `client_ip_address`: `<insert your public ip>/32`
   1. `enable_peering`: `false`

## Usage

### Set up regions and variables.

1. In each directory, you'll find a `terraform.auto.tfvars`.

1. By default, we set the following regions. You can change these,
   but you must change them across all files.
   - `datacenter` (VM): `us-east-2`
   - `cloud` (Kubernetes): `us-west-2`

### Set up datacenter and cloud deployments

1. Start a new run and apply changes to the `datacenter` workspace.

1. Start a new run and apply changes to the `cloud` workspace.

1. Go into `datacenter` workspace.
   1. Update the variable to set `enable_peering = true`. This sets up VPC peering
      between `cloud` and `datacenter` environments.
   1. Start a new run and apply changes to the `datacenter` workspace.

### Deploy Consul and example workload

1. Start a new run for the `consul` workspace.

1. Start a new run for the `application` workspace.

### Run Consul Terraform Sync to update ALB based on Consul service

1. Generate variables for Consul Terraform Sync to use in its module and save
   them in `consul_terraform_sync/datacenter.modules.tfvars`. This includes an ALB, listener rule,
   and target group created by the `datacenter` Terraform configuration. It also
   updates `config.local.hcl` with the Consul UI load balancer endpoint.
   ```shell
   make cts_variables
   ```

1. Run Consul Terraform Sync.
   ```shell
   make cts
   ```
## Test it out

1. To verify everything is working, get the load balancer's DNS and issue
   an HTTP GET request with the `Host` header set to `my-application.my-company.net`.
   The request should go to `datacenter`.
   ```shell
   $ make test

   {
      "name": "my-application (datacenter)",
      "uri": "/",
      "type": "HTTP",
      "ip_addresses": [
         "172.25.16.8"
      ],
      "start_time": "2021-08-26T16:43:12.552603",
      "end_time": "2021-08-26T16:43:12.552681",
      "duration": "77.835µs",
      "body": "my-application (datacenter)",
      "code": 200
   }
   ```

1. You can update the deployment to send a percentage of traffic to
   the `cloud` instances of `my-application.
   ```shell
   $ kubectl edit deployment my-application

   # update annotation - consul.hashicorp.com/service-meta-weight: "50"
   ```

1. CTS will pick up the change from the service metadata and update the
   ALB listener to send 50% of traffic to `cloud`.

## Clean up

1. Clean up CTS and the Consul deployment to Kubernetes.
   ```shell
   make clean
   ```

1. Go into Terraform Cloud and queue a destroy in the following order.
   1. `application`
   1. `consul`
   1. `cloud`
   1. `datacenter`

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