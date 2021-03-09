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

variable "tfc_organization" {
  type        = string
  description = "Terraform Cloud organization with datacenter state"
}

variable "tfc_workspace" {
  type        = string
  description = "Terraform Cloud workspace with datacenter state"
}

locals {
  tags = {
    Terraform   = "true"
    Environment = var.environment
    Datacenter  = var.datacenter
  }
}