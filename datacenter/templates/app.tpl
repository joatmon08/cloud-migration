#!/bin/bash

apt-get update && apt-get install -y unzip wget

# Versions
ENVOY_VERSION="1.16.2"
ENVOY_DOWNLOAD="https://getenvoy.io/cli"

CONSUL_VERSION="1.9.5"
CONSUL_DOWNLOAD="https://releases.hashicorp.com/consul/$${CONSUL_VERSION}/consul_$${CONSUL_VERSION}_linux_amd64.zip"

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
mkdir -p /etc/consul/certs

%{ if consul_ca_file != "" }
echo '${consul_ca_file}' | base64 -d > /etc/consul/certs/consul-agent-ca.pem
%{ endif }

cat << EOF > /etc/consul/config.hcl
data_dir = "/tmp/consul/client"

server         = false
advertise_addr = "$${LOCAL_IPV4}"
bind_addr      = "0.0.0.0"
client_addr    = "0.0.0.0"
retry_join     = ["${consul_http_addr}"]

datacenter = "${dc}"

%{ if consul_ca_file != "" }
ca_file = "/etc/consul/certs/consul-agent-ca.pem"
%{ endif }

ports {
  grpc = 8502
}

verify_incoming        = false
verify_outgoing        = true
verify_server_hostname = true

encrypt = "${consul_encrypt_key}"

auto_encrypt {
  tls = true
}

telemetry {
  prometheus_retention_time = "24h"
  disable_hostname          = true
}
EOF

# Create the service config
cat << EOF > /etc/consul/service.hcl
services {
  id   = "${app_name}"
  name = "${app_name}"
  tags = [
    "${dc}"
  ]
  address = "$${LOCAL_IPV4}"
  port    = 9090
  checks = [
    {
      id       = "${app_name}-http"
      name     = "HTTP on port 9090"
      tcp      = "$${LOCAL_IPV4}:9090"
      interval = "30s"
      timeout  = "60s"
    }
  ]
  connect {
    sidecar_service {
      port = 20000
      check {
        name     = "Connect Envoy Sidecar"
        tcp      = "$${LOCAL_IPV4}:20000"
        interval = "10s"
      }
      proxy {
        %{ if upstream != "" }
        upstreams {
          destination_name   = "${upstream}"
          local_bind_address = "127.0.0.1"
          local_bind_port    = 9091
          config {
            protocol = "http"
          }
        }
        %{ endif }
        config {
          protocol                   = "http"
          envoy_prometheus_bind_addr = "0.0.0.0:9102"
        }
      }
    }
  }
}
EOF

# Setup systemd
cat << EOF > /etc/systemd/system/consul.service
[Unit]
Description=Consul Server
After=syslog.target network.target
[Service]
ExecStart=/usr/bin/consul agent -config-dir=/etc/consul
ExecStop=/bin/sleep 5
Restart=always
[Install]
WantedBy=multi-user.target
EOF

chmod 644 /etc/systemd/system/consul.service

cat << EOF > /etc/systemd/system/consul-envoy.service
[Unit]
Description=Consul Envoy
After=syslog.target network.target
[Service]
ExecStart=/usr/bin/consul connect envoy -sidecar-for ${app_name}
ExecStop=/bin/sleep 5
Restart=always
[Install]
WantedBy=multi-user.target
EOF

chmod 644 /etc/systemd/system/consul-envoy.service

systemctl daemon-reload

# Enable and start the daemons
systemctl enable consul
systemctl enable consul-envoy

systemctl start consul
systemctl start consul-envoy

# Fetch Fake service
wget https://github.com/nicholasjackson/fake-service/releases/download/v${fake_service_version}/fake_service_linux_amd64.zip
unzip ./fake_service_linux_amd64.zip
mv ./fake-service /usr/local/bin/fake-service
chmod +x /usr/local/bin/fake-service

# Setup systemd fake service
cat << EOF > /etc/systemd/system/fake.service
[Unit]
Description=${description}
After=syslog.target network.target
[Service]
Environment="MESSAGE=${description}"
Environment="NAME=${description}"
Environment=ERROR_RATE=${error_rate}
Environment=UPSTREAM_URIS="${upstream_uris}"
ExecStart=/usr/local/bin/fake-service
ExecStop=/bin/sleep 5
Restart=always
[Install]
WantedBy=multi-user.target
EOF

chmod 644 /etc/systemd/system/fake.service

systemctl daemon-reload
systemctl start fake.service