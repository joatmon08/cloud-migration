resource "helm_release" "consul" {
  name = "consul"

  chart = "https://github.com/hashicorp/consul-helm/archive/${var.consul_helm_version}.tar.gz"

  values = [
    templatefile("templates/consul.tpl", {
      eks_cluster_name = var.eks_cluster_name
    })
  ]
}

resource "helm_release" "prometheus" {
  name = "prometheus"

  chart = "prometheus-community/prometheus"

  values = [
    templatefile("templates/prometheus.tpl", {})
  ]
}
