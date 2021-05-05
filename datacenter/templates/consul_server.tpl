#!/bin/bash
set -e

apt-get update && apt-get install -y unzip

# Versions
ENVOY_DOWNLOAD="https://getenvoy.io/cli"
ENVOY_VERSION="1.16.2"

CONSUL_DOWNLOAD="1.9.5"
CONSUL_VERSION="https://releases.hashicorp.com/consul/$${CONSUL_VERSION}/consul_$${CONSUL_VERSION}_linux_amd64.zip"

# Get internal IP
LOCAL_IPV4=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

cd /tmp

# Fetch Consul
curl -sSL --fail -o /tmp/consul.zip $${CONSUL_DOWNLOAD}
unzip -d /tmp /tmp/consul.zip
mv /tmp/consul /usr/bin/consul
chmod +x /usr/bin/consul

# Fetch Envoy
curl -sSL --fail $${ENVOY_DOWNLOAD} | sudo bash -s -- -b /usr/local/bin
getenvoy run standard:$${ENVOY_VERSION} -- --version
cp ~/.getenvoy/builds/standard/$${ENVOY_VERSION}/linux_glibc/bin/envoy /usr/bin/

# Create the consul config
mkdir -p /etc/consul

cat << EOF > /etc/consul/config.hcl
data_dir = "/tmp/consul/server"

server           = true
bootstrap_expect = 1
ui               = true
advertise_addr   = "$${LOCAL_IPV4}"
client_addr      = "0.0.0.0"
bind_addr        = "0.0.0.0"

ports {
  grpc = 8502
}

enable_central_service_config = true

ui_config {
  enabled          = true
  metrics_provider = "prometheus"
  metrics_proxy {
    base_url = "${prometheus_url}"
  }
}

connect {
  enabled = true
  enable_mesh_gateway_wan_federation = true
}

datacenter = "${dc}"

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
      mesh_gateway = {
        mode                       = "local"
      }
    }
  ]
}
EOF

# Setup system D
cat << EOF > /etc/systemd/system/consul.service
[Unit]
Description=Consul Server
After=syslog.target network.target
[Service]
ExecStart=/usr/local/bin/consul agent -config-file=/etc/consul/config.hcl
ExecStop=/bin/sleep 5
Restart=always
[Install]
WantedBy=multi-user.target
EOF

chmod 644 /etc/systemd/system/consul.service

systemctl start consul.service

# Setup systemd for gateway
cat << EOF > /etc/systemd/system/consul-gateway.service
[Unit]
Description=Consul Mesh Gateway
After=syslog.target network.target
[Service]
Environment=CONSUL_HTTP_ADDR=$${LOCAL_IPV4}:8500
Environment=CONSUL_GRPC_ADDR=$${LOCAL_IPV4}:8502
ExecStart=/usr/local/bin/consul connect envoy -gateway mesh -register -address $${LOCAL_IPV4}:8443 -wan-address ${dc_public_ip}:8443
ExecStop=/bin/sleep 5
Restart=always
[Install]
WantedBy=multi-user.target
EOF

chmod 644 /etc/systemd/system/consul-gateway.service

systemctl start consul-gateway.service

systemctl daemon-reload
systemctl start consul.service