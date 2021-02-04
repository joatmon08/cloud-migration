variable "aws_access_key_id" {
  sensitive = true
}

variable "aws_secret_access_key" {
  sensitive = true
}

variable "aws_session_token" {
  sensitive = true
}

variable "role_arn" {
  type        = string
  description = "Role ARN for provider to assume"
}

variable "region" {
  type        = string
  description = "AWS region to deploy the network"
}

variable "eks_cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "consul_terraform_sync_version" {
  type        = string
  description = "Docker image for Consul Terraform Sync"
}

variable "kubernetes_context" {
  type        = string
  description = "Kubernetes context in kubeconfig"
}