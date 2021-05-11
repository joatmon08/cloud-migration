#!/bin/bash

## Port forward everything
kubectl port-forward service/consul-ui 8500:80 &
CONSUL_PID=$!

hal deploy connect

echo $CONSUL_PID >> pid_file