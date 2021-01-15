variable "region" {
  type        = string
  description = "AWS region to deploy the network"
}

variable "datacenter_region" {
  type        = string
  description = "Region for datacenter"
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

locals {
  tags = {
    Terraform   = "true"
    Environment = var.environment
    Datacenter  = var.datacenter
  }
}