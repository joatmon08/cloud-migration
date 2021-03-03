global:
  name: consul
  datacenter: ${eks_cluster_name}

server:
  # use 1 server
  replicas: 1
  bootstrapExpect: 1
  disruptionBudget:
    enabled: true
    maxUnavailable: 0
  extraConfig: |
    {
      "telemetry": {
        "prometheus_retention_time": "10s"
      },
      "ui_config": {
        "enabled": true,
        "metrics_provider": "prometheus",
        "metrics_proxy": {
          "base_url": "http://prometheus-server"
        }
      }
    }

client:
  enabled: true
  grpc: true

connectInject:
  enabled: true

ui:
  enabled: true

controller:
  enabled: true

ingressGateways:
  enabled: true
  gateways:
    - name: ingress-gateway
      replicas: 1
      service:
        type: NodePort
        ports:
          - port: 9090
            nodePort: 30909

terminatingGateways:
  enabled: true
  gateways:
    - name: terminating-gateway
      replicas: 1