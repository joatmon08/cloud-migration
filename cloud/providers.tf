terraform {
  required_version = ">=1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.55"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~>2.4"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.15"
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

provider "hcp" {}