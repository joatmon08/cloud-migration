locals {
  name = "consul-terraform-sync"
  port = 8558
}

resource "kubernetes_secret" "consul_terraform_sync" {
  metadata {
    name = local.name
  }

  data = {
    AWS_ACCESS_KEY_ID     = var.aws_access_key_id
    AWS_SECRET_ACCESS_KEY = var.aws_secret_access_key
    AWS_SESSION_TOKEN     = var.aws_session_token
    AWS_ROLE_ARN          = var.role_arn
  }
}

resource "kubernetes_config_map" "consul_terraform_sync" {
  metadata {
    name = local.name
  }

  data = {
    "config.hcl"               = file("${path.module}/config.hcl")
    "datacenter.module.tfvars" = file("${path.module}/datacenter.module.tfvars")
  }
}

resource "kubernetes_service" "consul_terraform_sync" {
  metadata {
    name = local.name
  }
  spec {
    selector = {
      app = local.name
    }
    session_affinity = "ClientIP"
    port {
      port        = local.port
      target_port = local.port
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_deployment" "consul_terraform_sync" {
  metadata {
    name = local.name
    labels = {
      app = local.name
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = local.name
      }
    }

    template {
      metadata {
        labels = {
          app = local.name
        }
      }

      spec {
        volume {
          name = local.name
          config_map {
            name = kubernetes_config_map.consul_terraform_sync.metadata.0.name
          }
        }

        container {
          image = var.consul_terraform_sync_version
          name  = local.name
          command = [
            "consul-terraform-sync"
          ]
          args = [
            "-config-dir=/opt/consul-terraform-sync"
          ]
          env_from {
            secret_ref {
              name = kubernetes_secret.consul_terraform_sync.metadata.0.name
            }
          }
          port {
            container_port = local.port
          }
          volume_mount {
            name       = local.name
            mount_path = "/opt/consul-terraform-sync"
          }
        }
      }
    }
  }
}