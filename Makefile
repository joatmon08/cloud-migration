kubeconfig:
	aws eks --region us-west-2 update-kubeconfig --name cloud --alias cloud-migration

cts_variables:
	bash generate_cts_variables.sh

cts:
	cd consul_terraform_sync && consul-terraform-sync -config-file config.local.hcl

test:
	curl -H 'Host:my-application.my-company.net' $(shell cd datacenter && terraform output -raw alb_dns_name)

clean:
	cd consul_terraform_sync/sync-tasks/canary && $(shell pwd)/consul_terraform_sync/terraform destroy -no-color -auto-approve -input=false -var-file=terraform.tfvars -var-file=providers.tfvars -var-file=$(shell pwd)/consul_terraform_sync/datacenter.module.tfvars -var-file=$(shell pwd)/consul_terraform_sync/service.tfvars -lock=true -parallelism=10 -refresh=true