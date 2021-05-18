terraform {
  required_version = ">=0.14"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.23"
    }
  }
}

provider "aws" {
  alias  = "datacenter"
  region = var.region
}

provider "aws" {
  alias  = "cloud"
  region = var.cloud_region
}