global:
  name: consul
  datacenter: ${eks_cluster_name}
  tls:
    enabled: true
    enableAutoEncrypt: true
  metrics:
    enabled: true
  federation:
    enabled: true
    createFederationSecret: true

server:
  replicas: 1

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
  replicas: 1
  annotations: |
    'service.beta.kubernetes.io/aws-load-balancer-internal': "true"