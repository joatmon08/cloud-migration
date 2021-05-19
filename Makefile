kubeconfig:
	aws eks --region us-west-2 update-kubeconfig --name cloud --role-arn ${TF_VAR_role_arn} --alias eks-spinnaker

consul-proxy:
	kubectl apply -f kubernetes/

consul-federate: consul-proxy
	bash federate.sh

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
	kubectl delete -f kubernetes/ --ignore-not-found
	rm -f *consul*.pem
	rm -f datacenter/credentials.auto.tfvars
