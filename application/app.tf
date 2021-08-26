locals {
  app_port = 9090
}

resource "kubernetes_service_account" "app" {
  metadata {
    name = var.application_name
  }
  automount_service_account_token = true
}

resource "kubernetes_service" "app" {
  metadata {
    name = var.application_name
  }
  spec {
    selector = {
      app = var.application_name
    }
    session_affinity = "ClientIP"
    port {
      port        = local.app_port
      target_port = local.app_port
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_deployment" "app" {
  metadata {
    name = var.application_name
    labels = {
      app = var.application_name
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = var.application_name
      }
    }

    template {
      metadata {
        labels = {
          app = var.application_name
        }
        annotations = {
          "consul.hashicorp.com/connect-inject" : "true",
          "consul.hashicorp.com/connect-service-port" : local.app_port,
          "consul.hashicorp.com/service-meta-weight" : 0
        }
      }

      spec {
        service_account_name = kubernetes_service_account.app.metadata.0.name
        container {
          image = "nicholasjackson/fake-service:v0.19.1"
          name  = var.application_name

          env {
            name  = "LISTEN_ADDR"
            value = "0.0.0.0:${local.app_port}"
          }

          env {
            name  = "NAME"
            value = "${var.application_name} (${var.eks_cluster_name})"
          }

          env {
            name  = "MESSAGE"
            value = "${var.application_name} (${var.eks_cluster_name})"
          }

          env {
            name  = "ERROR_RATE"
            value = var.error_rate
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = local.app_port
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }
      }
    }
  }
}