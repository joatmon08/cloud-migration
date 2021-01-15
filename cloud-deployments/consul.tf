resource "helm_release" "consul" {
  name = "consul"

  chart = "https://github.com/hashicorp/consul-helm/archive/${var.consul_helm_version}.tar.gz"

  set {
    name  = "global.datacenter"
    value = var.eks_cluster_name
  }

  set {
    name  = "controller.enabled"
    value = true
  }

  set {
    name  = "connectInject.enabled"
    value = true
  }
}