module "hcp" {
  count  = var.hcp_consul_enable ? 1 : 0
  source = "joatmon08/hcp/aws"
  providers = {
    aws = aws.cloud
  }
  version        = "2.0.1"
  hvn_cidr_block = var.hvn_cidr_block
  hvn_name       = var.environment
  hvn_region     = var.region

  vpc_cidr_block = module.vpc.vpc_cidr_block
  vpc_id         = module.vpc.vpc_id
  vpc_owner_id   = module.vpc.vpc_owner_id

  number_of_route_table_ids = length(local.route_table_ids)
  route_table_ids           = local.route_table_ids

  hcp_consul_security_group_ids = [module.eks.cluster_primary_security_group_id]

  hcp_consul_name            = var.environment
  hcp_consul_public_endpoint = true
}
