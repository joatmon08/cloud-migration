module "hcp" {
  source         = "joatmon08/hcp/aws"
  version        = "2.0.1"
  hvn_cidr_block = var.hvn_cidr_block
  hvn_name       = var.environment
  hvn_region     = var.hcp_region
  hvn_peer       = false

  hcp_consul_name            = var.environment
  hcp_consul_datacenter      = var.datacenter
  hcp_consul_public_endpoint = true
}
