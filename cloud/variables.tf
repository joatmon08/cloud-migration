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

variable "hvn_cidr_block" {
  type        = string
  description = "CIDR block for HCP network"
  default     = "10.2.0.0/20"
}

locals {
  tags = {
    Terraform   = "true"
    Environment = var.environment
    Datacenter  = var.datacenter
  }
}