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
  region = var.region
  assume_role {
    role_arn     = var.role_arn
    session_name = "terraform"
    external_id  = "terraform"
  }
}