#!/bin/bash

TARGET_GROUP_ARN=$(cd datacenter && terraform output -raw blue_target_group_arn)
LISTENER_ARN=$(cd datacenter && terraform output -raw listener_arn)
VPC_ID=$(cd datacenter && terraform output -raw vpc_id)

cat << EOF > canary/datacenter.module.tfvars
blue_target_group_arn = "${TARGET_GROUP_ARN}"
listener_arn          = "${LISTENER_ARN}"
vpc_id                = "${VPC_ID}"
EOF

CONSUL_HTTP_ADDR=$(kubectl get services/consul-ui -o=jsonpath='{.status.loadBalancer.ingress[0].hostname}')
DIR=$(pwd)

sed -i.bak "s/CONSUL_HTTP_ADDR/${CONSUL_HTTP_ADDR}/g" canary/config.local.hcl
sed -i.bak 's:PWD:'`pwd`':' canary/config.local.hcl