#!/bin/bash

kubectl get secrets/consul-ca-cert --template='{{index .data "tls.crt" }}' | base64 -D > consul-agent-ca.pem
kubectl get secrets/consul-ca-key --template='{{index .data "tls.key" }}' | base64 -D > consul-agent-ca-key.pem
consul tls cert create -server -dc=datacenter -node="*"

CONSUL_CERT_FILE=$(cat datacenter-server-consul-0.pem | base64)
CONSUL_KEY_FILE=$(cat datacenter-server-consul-0-key.pem | base64)
CONSUL_CA_FILE=$(cat consul-agent-ca.pem | base64)
CONSUL_ENCRYPT_KEY=$(kubectl get secrets/consul-gossip-encryption-key --template='{{index .data "key" }}' | base64 -D)
CONSUL_PRIMARY_GATEWAY=$(kubectl exec statefulset/consul-server -- sh -c 'curl -sk https://localhost:8501/v1/catalog/service/mesh-gateway | jq ".[].ServiceTaggedAddresses.wan.Address"')


cat <<EOF > datacenter/credentials.auto.tfvars
consul_cert_file = "$CONSUL_CERT_FILE"
consul_key_file = "$CONSUL_KEY_FILE"
consul_ca_file = "$CONSUL_CA_FILE"
consul_encrypt_key = "$CONSUL_ENCRYPT_KEY"
consul_primary_gateway = "$CONSUL_PRIMARY_GATEWAY:443"
EOF