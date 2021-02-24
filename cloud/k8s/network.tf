data "aws_availability_zones" "available" {
  provider = aws.cloud
  state    = "available"
}

data "aws_vpc" "datacenter" {
  provider = aws.datacenter
  tags = {
    Terraform   = "true"
    Environment = var.environment
    Datacenter  = "datacenter"
  }
}

module "vpc" {
  providers = {
    aws = aws.cloud
  }
  source  = "terraform-aws-modules/vpc/aws"
  version = "~>2.64"

  name = var.datacenter
  cidr = "10.0.1.0/24"

  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = ["10.0.1.0/28", "10.0.1.16/28", "10.0.1.32/28"]
  public_subnets  = ["10.0.1.208/28", "10.0.1.224/28", "10.0.1.240/28"]

  enable_nat_gateway = true
  single_nat_gateway = false

  tags = local.tags
}

resource "aws_vpc_peering_connection" "datacenter" {
  provider    = aws.cloud
  peer_vpc_id = data.aws_vpc.datacenter.id
  peer_region = var.datacenter_region
  vpc_id      = module.vpc.vpc_id

  tags = merge({ Name = "${var.datacenter}-to-datacenter" }, local.tags)
}

locals {
  route_table_ids = concat(module.vpc.private_route_table_ids, module.vpc.public_route_table_ids)
}

resource "aws_route" "peering" {
  count                     = length(local.route_table_ids)
  provider                  = aws.cloud
  route_table_id            = local.route_table_ids[count.index]
  destination_cidr_block    = data.aws_vpc.datacenter.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.datacenter.id
}