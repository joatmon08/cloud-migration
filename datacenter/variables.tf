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
  default     = "0.22.7"
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

locals {
  tags = {
    Terraform   = "true"
    Environment = var.environment
    Datacenter  = var.datacenter
  }
}