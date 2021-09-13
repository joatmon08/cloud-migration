output "hcp_consul_cluster" {
  value = module.hcp.hcp_consul_id
}

output "hcp_consul_private_address" {
  value = module.hcp.hcp_consul_private_endpoint
}