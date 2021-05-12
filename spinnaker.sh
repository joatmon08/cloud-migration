#!/bin/bash

CONTEXT=$(kubectl config current-context)
VERSION=1.24.4

hal config version edit --version ${VERSION}

kubectl apply --context ${CONTEXT} \
    -f https://spinnaker.io/downloads/kubernetes/service-account.yml

TOKEN=$(kubectl get secret --context ${CONTEXT} \
   $(kubectl get serviceaccount spinnaker-service-account \
       --context ${CONTEXT} \
       -n spinnaker \
       -o jsonpath='{.secrets[0].name}') \
   -n spinnaker \
   -o jsonpath='{.data.token}' | base64 --decode)

kubectl config set-credentials ${CONTEXT}-token-user --token $TOKEN
kubectl config set-context ${CONTEXT} --user ${CONTEXT}-token-user

hal config provider kubernetes enable

hal config provider kubernetes account add 'eks-spinnaker' \
    --provider-version v2 \
    --context ${CONTEXT}

hal config deploy edit --type distributed --account-name eks-spinnaker

MINIO_ACCESS_KEY=$(kubectl get -n storage secret s3-storage -o jsonpath="{.data.accesskey}" | base64 --decode)
MINIO_SECRET_KEY=$(kubectl get -n storage secret s3-storage -o jsonpath="{.data.secretkey}" | base64 --decode)
ENDPOINT=http://s3-storage.storage.svc.cluster.local:9000

echo $MINIO_SECRET_KEY | hal config storage s3 edit --path-style-access true \
    --endpoint $ENDPOINT --access-key-id $MINIO_ACCESS_KEY --secret-access-key
hal config storage edit --type s3

hal config features edit --mine-canary true

hal config canary enable
hal config canary prometheus enable
hal config canary prometheus account add metrics --base-url http://prometheus-server.default.svc.cluster.local

hal config canary aws enable
hal config canary aws edit --s3-enabled=true
echo $MINIO_SECRET_KEY | hal config canary aws account add minio \
    --bucket spin-bucket --endpoint $ENDPOINT --access-key-id $MINIO_ACCESS_KEY --secret-access-key

hal config canary edit --default-metrics-store prometheus
hal config canary edit --default-metrics-account metrics
hal config canary edit --default-storage-account minio

hal deploy apply