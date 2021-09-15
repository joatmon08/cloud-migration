output "hcp_consul_cluster" {
  value = var.hcp_consul_enable ? module.hcp.0.hcp_consul_id : ""
}

output "hcp_consul_private_address" {
  value = var.hcp_consul_enable ? module.hcp.0.hcp_consul_private_endpoint : ""
}