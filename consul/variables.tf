variable "eks_cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "region" {
  type        = string
  description = "AWS region to deploy the network"
}

variable "consul_helm_version" {
  type        = string
  description = "version of Consul Helm chart"
}
