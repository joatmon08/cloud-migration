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