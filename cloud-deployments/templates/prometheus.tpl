global:
  scrape_interval:  5s
  scrape_timeout: 3s

server:
  persistentVolume:
    enabled: false
  service:
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-internal: "true"
    type: LoadBalancer

alertmanager:
  enabled: false

serviceFiles:
  prometheus.yml:
    scrape_configs:
      - job_name: "envoy"
        metrics_path: /metrics
        consul_sd_configs:
          - server: "consul-server:8501"
            scheme: "https"
