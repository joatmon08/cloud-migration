kubeconfig:
	aws eks --region us-west-2 update-kubeconfig --name cloud --role-arn ${TF_VAR_role_arn} --alias cloud-migration

consul_terraform_sync_variables:
	bash generate_cts_variables.sh