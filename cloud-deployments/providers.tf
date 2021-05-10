terraform {
  required_version = ">=0.14"
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~>3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~>2.0"
    }
    kubernetes-alpha = {
      source  = "hashicorp/kubernetes-alpha"
      version = "~> 0.3"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~>2.0"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = var.kubernetes_context
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = var.kubernetes_context
}

provider "kubernetes-alpha" {
  config_path    = "~/.kube/config"
  config_context = var.kubernetes_context
}
