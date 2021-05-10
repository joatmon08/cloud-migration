kubeconfig:
	aws eks --region us-west-2 update-kubeconfig --name cloud --role-arn ${TF_VAR_role_arn}

federate:
	kubectl get secrets/consul-ca-cert --template='{{index .data "tls.crt" }}' | base64 -D > consul-agent-ca.pem
	kubectl get secrets/consul-ca-key --template='{{index .data "tls.key" }}' | base64 -D > consul-agent-ca-key.pem
	consul tls cert create -server -dc=datacenter -node="*"
	consul tls cert create -client -dc=datacenter
	cat datacenter-server-consul-0.pem | base64 > datacenter/credentials
	cat datacenter-server-consul-0-key.pem | base64 >> datacenter/credentials
	cat datacenter-client-consul-0.pem | base64 >> datacenter/credentials
	cat datacenter-client-consul-0-key.pem | base64 >> datacenter/credentials
	cat consul-agent-ca.pem | base64 >> datacenter/credentials