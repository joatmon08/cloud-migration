global:
  name: consul
  datacenter: ${eks_cluster_name}
  tls:
    enabled: true
    caCert:
      secretName: consul-federation
      secretKey: caCert
    caKey:
      secretName: consul-federation
      secretKey: caKey
  metrics:
    enabled: true
  federation:
    enabled: true

prometheus:
  enabled: true

server:
  replicas: 1
  extraConfig: |
    {
      "primary_datacenter": "<your VM datacenter name>",
      "primary_gateways": ["<ip of your VM mesh gateway>", "<other ip>", ...]
    }

client:
  enabled: true

connectInject:
  enabled: true

ui:
  enabled: true

controller:
  enabled: true

meshGateway:
  enabled: true