kubeconfig:
	aws eks --region us-west-2 update-kubeconfig --name cloud --role-arn ${TF_VAR_role_arn} --alias eks-spinnaker

consul-federate:
	kubectl get secrets/consul-ca-cert --template='{{index .data "tls.crt" }}' | base64 -D > consul-agent-ca.pem
	kubectl get secrets/consul-ca-key --template='{{index .data "tls.key" }}' | base64 -D > consul-agent-ca-key.pem
	consul tls cert create -server -dc=datacenter -node="*"
	consul tls cert create -client -dc=datacenter
	cat datacenter-server-consul-0.pem | base64 > datacenter/consul_cert_file
	cat datacenter-server-consul-0-key.pem | base64 > datacenter/consul_key_file
	cat consul-agent-ca.pem | base64 > datacenter/consul_ca_file
	kubectl exec statefulset/consul-server -- sh -c 'curl -sk https://localhost:8501/v1/catalog/service/mesh-gateway | jq ".[].ServiceTaggedAddresses.wan"' > datacenter/primary_gateway

consul-test:
	kubectl apply -f kubernetes/

spinnaker-deploy:
	bash spinnaker.sh
	hal deploy apply

spinnaker-pipelines:
	spin application save -f spinnaker/application.json
	spin canary canary-config save --file spinnaker/canary-config.json
	spin pipeline save -f spinnaker/deploy.json

spinnaker-pipelines-export:
	spin application get my-application > spinnaker/application.json
	spin canary canary-config get --id 0afb9a63-1182-4911-b80c-836e4d6e4e76 > spinnaker/canary-config.json
	spin pipeline get --application my-application --name Deploy > spinnaker/deploy.json

load-test:
	k6 run -e UI_ENDPOINT=http://$(shell cd datacenter && terraform output -raw ui_endpoint) k6/script.js --duration 120m

clean:
	bash shutdown.sh || true
	kubectl delete -f kubernetes/
	rm -f *consul*.pem
