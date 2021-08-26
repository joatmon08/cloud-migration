locals {
  ui_port = 8080
  ui_name = "ui"
}

resource "kubernetes_service_account" "app" {
  metadata {
    name = local.ui_name
  }
  automount_service_account_token = true
}

resource "kubernetes_service" "ui" {
  metadata {
    name = local.ui_name
  }
  spec {
    selector = {
      app = local.ui_name
    }
    session_affinity = "ClientIP"
    port {
      port        = local.ui_port
      target_port = local.ui_port
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_deployment" "ui" {
  metadata {
    name = local.ui_name
    labels = {
      app = local.ui_name
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = local.ui_name
      }
    }

    template {
      metadata {
        labels = {
          app = local.ui_name
        }
        annotations = {
          "consul.hashicorp.com/connect-inject" : "true",
          "consul.hashicorp.com/connect-service-port" : local.ui_port,
        }
      }

      spec {
        service_account_name = kubernetes_service_account.app.metadata.0.name
        container {
          image = "nicholasjackson/fake-service:v0.22.7"
          name  = local.ui_name

          env {
            name  = "LISTEN_ADDR"
            value = "0.0.0.0:${local.ui_port}"
          }

          env {
            name  = "UPSTREAM_URIS"
            value = "${var.application_name}:${local.app_port}"
          }

          env {
            name  = "NAME"
            value = "${local.ui_name} (${var.eks_cluster_name})"
          }

          env {
            name  = "MESSAGE"
            value = "${local.ui_name} (${var.eks_cluster_name})"
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = local.ui_port
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }
      }
    }
  }
}