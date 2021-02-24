resource "helm_release" "consul" {
  name = "consul"

  chart = "https://github.com/hashicorp/consul-helm/archive/${var.consul_helm_version}.tar.gz"

  values = [
    templatefile("values.yaml", {
      eks_cluster_name = var.eks_cluster_name
    })
  ]
}