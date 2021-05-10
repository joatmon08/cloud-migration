variable "region" {
  type        = string
  description = "AWS region to deploy the network"
}

variable "datacenter" {
  type        = string
  description = "name of the datacenter"
}

variable "environment" {
  type        = string
  description = "environment"
}

variable "role_arn" {
  type        = string
  description = "Role ARN for provider to assume"
}

variable "cloud_region" {
  type        = string
  description = "AWS region for peering connections to cloud"
}

variable "enable_peering" {
  type        = string
  description = "accept peering connections with other VPCs"
  default     = false
}

variable "fake_service_version" {
  type        = string
  description = "version of fake service"
  default     = "0.19.1"
}

variable "application_name" {
  type        = string
  description = "application name"
  default     = "my-application"
}

variable "client_ip_address" {
  type        = string
  description = "IP address to connect to load balancer"
}

variable "consul_cert_file" {
  type        = string
  description = "Consul datacenter certificate contents, base64 encoded"
  sensitive   = true
  default     = ""
}

variable "consul_key_file" {
  type        = string
  description = "Consul datacenter certificate key file contents, base64 encoded"
  sensitive   = true
  default     = ""
}

variable "consul_ca_file" {
  type        = string
  description = "Consul datacenter certificate authority base64 encoded"
  sensitive   = true
  default     = ""
}

variable "primary_gateway" {
  type        = string
  description = "Consul primary mesh gateway from Kubernetes"
  default     = ""
}

locals {
  tags = {
    Terraform   = "true"
    Environment = var.environment
    Datacenter  = var.datacenter
  }
}