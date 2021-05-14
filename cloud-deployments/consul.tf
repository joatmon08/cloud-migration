resource "kubernetes_secret" "consul_gossip_encryption_key" {
  metadata {
    name = "consul-gossip-encryption-key"
  }

  data = {
    key = var.consul_encrypt_key
  }

  type = "Opaque"
}

resource "helm_release" "consul" {
  depends_on = [kubernetes_secret.consul_gossip_encryption_key]
  name       = "consul"

  chart = "https://github.com/hashicorp/consul-helm/archive/${var.consul_helm_version}.tar.gz"

  values = [
    templatefile("templates/consul.tpl", {
      eks_cluster_name = var.eks_cluster_name
    })
  ]
}