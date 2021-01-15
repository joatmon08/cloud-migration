#!/bin/bash

cd /tmp

sudo mv ./my-application.service /etc/systemd/system/my-application.service
sudo chmod 664 /etc/systemd/system/my-application.service

wget https://github.com/nicholasjackson/fake-service/releases/download/v0.19.1/fake_service_linux_amd64.zip
unzip fake_service_linux_amd64.zip
sudo mv fake-service /usr/sbin/fake-service

sudo systemctl daemon-reload
sudo systemctl start my-application
sudo systemctl enable my-application