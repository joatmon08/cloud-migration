terraform {
  required_version = ">=0.14"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.23"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~>1.13.3"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~>2.0.1"
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

data "aws_eks_cluster" "cloud" {
  name = var.eks_cluster_name
}

data "aws_eks_cluster_auth" "cloud" {
  name = var.eks_cluster_name
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cloud.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cloud.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cloud.token
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cloud.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cloud.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cloud.token
  load_config_file       = false
}