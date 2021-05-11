#!/bin/bash

hal config provider kubernetes account edit 'demo' \
    --provider-version v2 \
    --context $(kubectl config current-context)

hal config deploy edit --type distributed --account-name demo

MINIO_ACCESS_KEY=$(kubectl get -n storage secret s3-storage -o jsonpath="{.data.accesskey}" | base64 --decode)
MINIO_SECRET_KEY=$(kubectl get -n storage secret s3-storage -o jsonpath="{.data.secretkey}" | base64 --decode)
ENDPOINT=http://s3-storage.storage.svc.cluster.local:9000

echo $MINIO_SECRET_KEY | hal config storage s3 edit --path-style-access true \
    --endpoint $ENDPOINT --access-key-id $MINIO_ACCESS_KEY --secret-access-key
hal config storage edit --type s3

hal config features edit --mine-canary true

hal config canary prometheus enable
hal config canary prometheus account edit metrics --base-url http://prometheus-server.default.svc.cluster.local
echo $MINIO_SECRET_KEY | hal config canary aws account edit minio \
    --bucket spin-bucket --endpoint $ENDPOINT --access-key-id $MINIO_ACCESS_KEY --secret-access-key
hal config canary aws edit --s3-enabled=true

hal config canary edit --default-metrics-store prometheus
hal config canary edit --default-metrics-account metrics
hal config canary edit --default-storage-account minio

hal deploy apply