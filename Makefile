kubeconfig:
	aws eks --region us-west-2 update-kubeconfig --name cloud --alias cloud-migration

consul_certs:
	cd datacenter/certs && consul tls ca create
	cd datacenter/certs && consul tls cert create -server -dc datacenter

consul_secrets:
	echo "consul_encrypt_key=\"$(shell consul keygen)\"" > datacenter/secrets.tfvars
	echo "consul_ca_file=\"$(shell cat datacenter/certs/consul-agent-ca.pem | base64)\"" >> datacenter/secrets.tfvars
	echo "consul_cert_file=\"$(shell cat datacenter/certs/datacenter-server-consul-0.pem | base64)\"" >> datacenter/secrets.tfvars
	echo "consul_key_file=\"$(shell cat datacenter/certs/datacenter-server-consul-0-key.pem | base64)\"" >> datacenter/secrets.tfvars

consul_acl_bootstrap:
	curl --request PUT http:/$(shell cd datacenter && terraform output -raw consul_server):8500/v1/acl/bootstrap > consul_acl_bootstrap.json

cts_variables:
	bash generate_cts_variables.sh

cts:
	cd consul_terraform_sync && consul-terraform-sync -config-file config.local.hcl

weight:
	kubectl patch deployment my-application --type='json' -p='[{"op": "replace", "path": "/spec/template/metadata/annotations/consul.hashicorp.com~1service-meta-weight", "value":"0"}]'

test:
	curl -H 'Host:my-application.my-company.net' $(shell cd datacenter && terraform output -raw alb_dns_name)

clean:
	cd consul_terraform_sync/sync-tasks/canary && $(shell pwd)/consul_terraform_sync/terraform destroy -no-color -auto-approve -input=false -var-file=terraform.tfvars -var-file=providers.tfvars -var-file=$(shell pwd)/consul_terraform_sync/datacenter.module.tfvars -var-file=$(shell pwd)/consul_terraform_sync/service.tfvars -lock=true -parallelism=10 -refresh=true