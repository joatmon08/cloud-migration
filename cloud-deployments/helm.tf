resource "helm_release" "consul" {
  name = "consul"

  chart = "https://github.com/hashicorp/consul-helm/archive/${var.consul_helm_version}.tar.gz"

  values = [
    templatefile("templates/consul.tpl", {
      eks_cluster_name = var.eks_cluster_name
    })
  ]
}

resource "helm_release" "loki" {
  name = "loki"

  chart = "https://github.com/grafana/helm-charts/releases/download/loki-stack-${var.loki_stack_helm_version}/loki-stack-${var.loki_stack_helm_version}.tgz"

  values = [
    templatefile("templates/loki.tpl", {})
  ]
}