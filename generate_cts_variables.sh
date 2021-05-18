#!/bin/bash

TARGET_GROUP_ARN=$(cd datacenter && terraform output -raw blue_target_group_arn)
LISTENER_ARN=$(cd datacenter && terraform output -raw listener_arn)
VPC_ID=$(cd datacenter && terraform output -raw vpc_id)

cat << EOF > canary/datacenter.module.tfvars
blue_target_group_arn = "${TARGET_GROUP_ARN}"
listener_arn          = "${LISTENER_ARN}"
vpc_id                = "${VPC_ID}"
EOF