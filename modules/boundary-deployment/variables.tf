resource "random_pet" "test" {
  length = 1
}

locals {
  tags = merge({
    Name = "${var.name}-${random_pet.test.id}"
  }, var.tags)
  boundary_bin         = var.boundary_bin == "" ? "${path.module}/bin" : var.boundary_bin
  private_ssh_key_path = var.private_ssh_key_path == "" ? "${path.module}/bin/id_rsa" : var.private_ssh_key_path
  public_ssh_key_path  = var.public_ssh_key_path == "" ? "${path.module}/bin/id_rsa.pub" : var.public_ssh_key_path
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet ids for Boundary"
  type        = list(string)
}

variable "name" {
  description = "name of resources"
  type        = string
}

variable "boundary_bin" {
  default = ""
}

variable "private_ssh_key_path" {
  default = ""
}

variable "public_ssh_key_path" {
  default = ""
}

variable "num_workers" {
  default = 1
}

variable "num_controllers" {
  default = 1
}

variable "tls_cert_path" {
  default = "/etc/pki/tls/boundary/boundary.cert"
}

variable "tls_key_path" {
  default = "/etc/pki/tls/boundary/boundary.key"
}

variable "tls_disabled" {
  default = true
}

variable "kms_type" {
  default = "aws"
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
}