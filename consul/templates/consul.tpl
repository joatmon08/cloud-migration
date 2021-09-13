global:
  name: consul
  datacenter: ${eks_cluster_name}

server:
  replicas: 1

client:
  enabled: true
  grpc: true

connectInject:
  enabled: true

ui:
  enabled: true
  service:
    type: LoadBalancer

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