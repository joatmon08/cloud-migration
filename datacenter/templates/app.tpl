#!/bin/bash

apt-get update && apt-get install -y unzip wget

# Get internal IP
LOCAL_IPV4=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

cd /tmp

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
ExecStart=/usr/local/bin/fake-service
ExecStop=/bin/sleep 5
Restart=always
[Install]
WantedBy=multi-user.target
EOF

chmod 644 /etc/systemd/system/fake.service

systemctl daemon-reload
systemctl start fake.service