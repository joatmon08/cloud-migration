resource "kubernetes_manifest" "service_defaults_my_application" {
  manifest = {
    "apiVersion" = "consul.hashicorp.com/v1alpha1"
    "kind"       = "ServiceDefaults"
    "metadata" = {
      "name"      = "my-application"
      "namespace" = "default"
    }
    "spec" = {
      "protocol" = "http"
    }
  }
}

resource "kubernetes_manifest" "ingressgateway_my_application" {
  manifest = {
    "apiVersion" = "consul.hashicorp.com/v1alpha1"
    "kind"       = "IngressGateway"
    "metadata" = {
      "name"      = "ingress-gateway"
      "namespace" = "default"
    }
    "spec" = {
      "listeners" = [
        {
          "port"     = 9090
          "protocol" = "http"
          "services" = [
            {
              "hosts" = [
                "my-application.my-company.net",
              ]
              "name" = "my-application"
            },
          ]
        },
      ]
    }
  }
}