#!/bin/bash
set -e

apt-get update && apt-get install -y unzip

# Versions
ENVOY_VERSION="1.18.4"
ENVOY_DOWNLOAD="https://func-e.io/install.sh"

# Get internal IP
LOCAL_IPV4=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

cd /tmp

# Fetch Consul
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt-get update && apt-get install -y consul

# Fetch Envoy
curl -sSL --fail $${ENVOY_DOWNLOAD} | sudo bash -s -- -b /usr/local/bin
func-e use $${ENVOY_VERSION}
func-e run --version
cp ~/.func-e/versions/$${ENVOY_VERSION}/bin/envoy /usr/bin/

# Create the consul config
mkdir -p /etc/consul
mkdir -p /etc/consul/certs

%{ if consul_cert_file != "" }
echo '${consul_cert_file}' | base64 -d > /etc/consul/certs/datacenter-server-consul-0.pem
%{ endif }

%{ if consul_key_file != "" }
echo '${consul_key_file}' | base64 -d > /etc/consul/certs/datacenter-server-consul-0-key.pem
%{ endif }

%{ if consul_ca_file != "" }
echo '${consul_ca_file}' | base64 -d > /etc/consul/certs/consul-agent-ca.pem
%{ endif }

cat << EOF > /etc/consul.d/config.hcl
data_dir = "/tmp/consul/server"

server           = true
bootstrap_expect = 1
ui               = true
advertise_addr   = "$${LOCAL_IPV4}"
client_addr      = "0.0.0.0"
bind_addr        = "0.0.0.0"

enable_central_service_config = true

%{ if primary_gateway != "" }
primary_gateways = ["${primary_gateway}"]
primary_datacenter = "cloud"
%{ endif }

%{ if consul_ca_file != "" }
cert_file = "/etc/consul/certs/datacenter-server-consul-0.pem"
key_file = "/etc/consul/certs/datacenter-server-consul-0-key.pem"
ca_file = "/etc/consul/certs/consul-agent-ca.pem"
%{ endif }

verify_incoming_rpc    = true
verify_outgoing        = true
verify_server_hostname = true

encrypt                 = "${consul_encrypt_key}"
encrypt_verify_incoming = true
encrypt_verify_outgoing = true

ports {
  https = 8501
  grpc  = 8502
}

auto_encrypt {
  allow_tls = true
}

enable_central_service_config = true

ui_config {
  enabled          = true
}

connect {
  enabled = true
  enable_mesh_gateway_wan_federation = %{ if primary_gateway != "" }true%{ else }false%{ endif }
}

datacenter = "${dc}"

acl {
  enabled        = true
  default_policy = "deny"
  down_policy    = "extend-cache"
}

telemetry {
  prometheus_retention_time = "24h"
  disable_hostname          = true
}

config_entries {
  bootstrap = [
    {
      kind = "proxy-defaults"
      name = "global"
      config {
        protocol                   = "http"
        envoy_prometheus_bind_addr = "0.0.0.0:9102"
      }
      %{ if primary_gateway != "" }
      mesh_gateway = {
        mode                       = "local"
      }
      %{ endif }
    }
  ]
}
EOF

systemctl start consul.service

%{ if primary_gateway != "" }
# Setup systemd for mesh gateway
cat << EOF > /etc/systemd/system/consul-gateway.service
[Unit]
Description=Consul Mesh Gateway
After=syslog.target network.target
[Service]
Environment=CONSUL_HTTP_ADDR=https://127.0.0.1:8501
Environment=CONSUL_GRPC_ADDR=$${LOCAL_IPV4}:8502
Environment=CONSUL_CACERT=/etc/consul/certs/consul-agent-ca.pem
ExecStart=/usr/bin/consul connect envoy -gateway mesh -register -address $${LOCAL_IPV4}:8443 -wan-address ${dc_public_ip}:8443 -expose-servers
ExecStop=/bin/sleep 5
Restart=always
[Install]
WantedBy=multi-user.target
EOF

chmod 644 /etc/systemd/system/consul-gateway.service

systemctl start consul-gateway.service
systemctl daemon-reload
systemctl restart consul.service
%{ endif }