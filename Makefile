kubeconfig:
	aws eks --region us-west-2 update-kubeconfig --name cloud --alias cloud-migration

consul_terraform_sync_variables:
	bash generate_cts_variables.sh

consul_terraform_sync:
	cd canary && consul-terraform-sync -config-file config.local.hcl

test:
	curl -H 'Host:my-application.my-company.net' $(shell cd datacenter && terraform output -raw alb_dns_name)

clean:
	cd canary/sync-tasks/canary && $(shell pwd)/canary/terraform destroy -no-color -auto-approve -input=false -var-file=terraform.tfvars -var-file=providers.tfvars -var-file=$(shell pwd)/canary/datacenter.module.tfvars -var-file=$(shell pwd)/canary/service.tfvars -lock=true -parallelism=10 -refresh=true
	cd cloud-deployments && terraform destroy -auto-approve