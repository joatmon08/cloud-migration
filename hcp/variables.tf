variable "hcp_region" {
  description = "HCP Region"
  type        = string
}


variable "hvn_cidr_block" {
  description = "HCP HVN CIDR Block"
  type        = string
}

variable "datacenter" {
  description = "HCP Consul datacenter"
  type        = string
}

variable "environment" {
  type        = string
  description = "environment"
}