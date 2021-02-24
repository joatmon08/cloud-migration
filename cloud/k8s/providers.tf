terraform {
  required_version = ">=0.14"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.23"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~>2.0"
    }
  }
}

provider "aws" {
  alias  = "datacenter"
  region = var.datacenter_region
  assume_role {
    role_arn     = var.role_arn
    session_name = "terraform"
    external_id  = "terraform"
  }
}

provider "aws" {
  alias  = "cloud"
  region = var.region
  assume_role {
    role_arn     = var.role_arn
    session_name = "terraform"
    external_id  = "terraform"
  }
}