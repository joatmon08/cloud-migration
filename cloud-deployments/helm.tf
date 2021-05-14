resource "helm_release" "prometheus" {
  name  = "prometheus"
  chart = "prometheus-community/prometheus"

  values = [
    file("templates/prometheus.yaml")
  ]
}

resource "helm_release" "minio" {
  name             = "s3"
  namespace        = "storage"
  create_namespace = true
  chart            = "minio/minio"
  version          = "8.0.10"

  values = [
    file("templates/minio.yaml")
  ]
}

resource "helm_release" "grafana" {
  name  = "grafana"
  chart = "grafana/grafana"
  values = [
    templatefile("templates/grafana.yaml", {
      dashboard_app = indent(8, file("dashboards/app.json"))
    })
  ]
}
