terraform {
  required_version = ">=1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.55"
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