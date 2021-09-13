data "hcp_consul_agent_kubernetes_secret" "cluster" {
  count      = var.hcp_consul_enable ? 1 : 0
  cluster_id = var.hcp_consul_cluster_id
}

data "hcp_consul_agent_helm_config" "cluster" {
  count               = var.hcp_consul_enable ? 1 : 0
  cluster_id          = var.hcp_consul_cluster_id
  kubernetes_endpoint = replace(data.aws_eks_cluster.cluster.endpoint, "https://", "")
}

resource "hcp_consul_cluster_root_token" "token" {
  count      = var.hcp_consul_enable ? 1 : 0
  cluster_id = var.hcp_consul_cluster_id
}

locals {
  consul_secrets    = var.hcp_consul_enable ? yamldecode(data.hcp_consul_agent_kubernetes_secret.cluster.0.secret) : ""
  consul_root_token = var.hcp_consul_enable ? yamldecode(hcp_consul_cluster_root_token.token.0.kubernetes_secret) : ""
  helm_values = var.hcp_consul_enable ? data.hcp_consul_agent_helm_config.cluster.0.config : templatefile("templates/consul.tpl", {
    eks_cluster_name = var.eks_cluster_name
  })
}

resource "kubernetes_secret" "hcp_consul_secret" {
  count = var.hcp_consul_enable ? 1 : 0
  metadata {
    name        = local.consul_secrets.metadata.name
    annotations = {}
    labels      = {}
  }

  data = {
    gossipEncryptionKey = base64decode(local.consul_secrets.data.gossipEncryptionKey)
    caCert              = base64decode(local.consul_secrets.data.caCert)
  }

  type = local.consul_secrets.type
}

resource "kubernetes_secret" "hcp_consul_token" {
  count = var.hcp_consul_enable ? 1 : 0
  metadata {
    name        = local.consul_root_token.metadata.name
    annotations = {}
    labels      = {}
  }

  data = {
    token = base64decode(local.consul_root_token.data.token)
  }

  type = local.consul_root_token.type
}

resource "helm_release" "consul" {
  depends_on = [kubernetes_secret.hcp_consul_secret, kubernetes_secret.hcp_consul_token]
  name       = "consul"

  repository = "https://helm.releases.hashicorp.com"
  chart      = "consul"
  version    = var.consul_helm_version

  values = [
    local.helm_values
  ]

  set {
    name  = "controller.enabled"
    value = "true"
  }

  set {
    name  = "terminatingGateways.enabled"
    value = "true"
  }

  set {
    name  = "terminatingGateways.defaults.replicas"
    value = "1"
  }
}
