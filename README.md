# Cloud Migration with Network Automation & Service Mesh

## Prerequisites

- [Consul](https://www.consul.io/downloads) v1.9+
- [Terraform](https://www.terraform.io/downloads.html) v0.14+
- [Halyard](https://spinnaker.io/setup/install/halyard/) v1.42.0+
- [spin CLI](https://spinnaker.io/guides/spin/) v1.22.0+
- Amazon Web Services

## Usage

1. Go into `datacenter` and run `terraform apply`.

1. Go into `cloud` and run `terraform apply`.

1. Set `kubectl` to the AWS EKS cluster in cloud.
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

1. In `credentials`, add the AWS role ARN, the Kubernetes context for EKS clusters.

1. Then, set the environment variables with the Terraform variables.
   ```shell
   source credentials
   ```

1. Deploy Consul Helm chart, ingress gateway configuration, and application to Kubernetes.
   ```shell
   terraform apply
   ```

1. Go to the top-level directory.
   ```shell
   cd ..
   ```

1. Retrieve the parameters for adding `datacenter` as a secondary datacenter. This includes
   certificates, certificate authority, and encryption key.
   ```shell
   make federate
   ```

1. The `datacenter` directory should contain a `credentials.auto.tfvars`. You need to set the variables in
   Terraform to the content of this file.
   ```shell
   datacenter/credentials.auto.tfvars
   ```

1. Go into `datacenter` and update the variable for `enable_peering = true`.
   Run `terraform apply` to accept the peering connection from cloud and reconfigure
   `datacenter` to federate with `cloud`, the primary datacenter.

1. Configure and create Spinnaker.
   ```shell
   make spinnaker-deploy
   ```

1. Run `hal deploy connect` to access Spinnaker UI on [http://localhost:9000](http://localhost:9000)
   and port forward the Spinnaker API.

1. Configure and create Spinnaker pipelines.
   ```shell
   make spinnaker-pipelines
   ```

## Accessing Spinnaker, Consul, and Grafana

- Run `kubectl port-forward services/grafana 3000:80` to access Grafana on [http://localhost:3000](http://localhost:3000). (username `admin`, password `password`)
- Run `kubectl port-forward services/consul-ui 8501:443` to access Consul on [https://localhost:8501](http://localhost:8501).

## Caveats

- In this demo, the "cloud" application is hosted on Kubernetes (for ease of deployment).
- The configuration peers two VPCs in two different regions.