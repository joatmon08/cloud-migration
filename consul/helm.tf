resource "helm_release" "consul" {
  name = "consul"

  repository = "https://helm.releases.hashicorp.com"
  chart      = "consul"
  version    = var.consul_helm_version

  values = [
    templatefile("templates/consul.tpl", {
      eks_cluster_name = var.eks_cluster_name
    })
  ]
}