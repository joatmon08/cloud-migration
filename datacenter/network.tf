data "aws_availability_zones" "available" {
  provider = aws.datacenter
  state    = "available"
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

module "vpc" {
  providers = {
    aws = aws.datacenter
  }
  source  = "terraform-aws-modules/vpc/aws"
  version = "~>2.64"

  name = var.datacenter
  cidr = "172.25.16.0/24"

  azs             = slice(data.aws_availability_zones.available.names, 0, 1)
  private_subnets = ["172.25.16.0/28"]
  public_subnets  = ["172.25.16.208/28"]


  # azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  # private_subnets = ["172.25.16.0/28", "172.25.16.16/28", "172.25.16.32/28"]
  # public_subnets  = ["172.25.16.208/28", "172.25.16.224/28", "172.25.16.240/28"]

  enable_nat_gateway = true
  single_nat_gateway = false

  tags = local.tags
}

data "aws_vpc" "cloud" {
  count    = var.enable_peering ? 1 : 0
  provider = aws.cloud
  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}

data "aws_vpc_peering_connection" "cloud" {
  count    = var.enable_peering ? 1 : 0
  provider = aws.datacenter
  vpc_id   = data.aws_vpc.cloud.0.id
}

resource "aws_vpc_peering_connection_accepter" "peer" {
  count                     = var.enable_peering ? 1 : 0
  provider                  = aws.datacenter
  vpc_peering_connection_id = data.aws_vpc_peering_connection.cloud.0.id
  auto_accept               = true

  tags = merge({ Peer = "cloud" }, local.tags)
}

locals {
  route_table_ids = concat(module.vpc.private_route_table_ids, module.vpc.public_route_table_ids)
}

resource "aws_route" "peering" {
  count                     = var.enable_peering ? length(local.route_table_ids) : 0
  provider                  = aws.datacenter
  route_table_id            = local.route_table_ids[count.index]
  destination_cidr_block    = data.aws_vpc.cloud.0.cidr_block
  vpc_peering_connection_id = data.aws_vpc_peering_connection.cloud.0.id
}