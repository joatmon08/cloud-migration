kubeconfig:
	aws eks --region us-west-2 update-kubeconfig --name cloud --role-arn ${TF_VAR_role_arn} --alias cloud-migration

consul_terraform_sync_variables:
	bash generate_cts_variables.sh

test:
	curl -H 'Host:my-application.my-company.net' $(shell cd datacenter && terraform output -raw alb_dns_name)