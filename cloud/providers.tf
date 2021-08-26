terraform {
  required_version = ">=0.14"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.55"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~>2.4"
    }
  }
}

provider "aws" {
  alias  = "datacenter"
  region = var.datacenter_region
}

provider "aws" {
  alias  = "cloud"
  region = var.region
}