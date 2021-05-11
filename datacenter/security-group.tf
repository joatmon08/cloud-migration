resource "aws_security_group_rule" "load_balancer" {
  provider          = aws.datacenter
  type              = "ingress"
  from_port         = 9090
  to_port           = 9090
  protocol          = "tcp"
  cidr_blocks       = [module.vpc.vpc_cidr_block]
  security_group_id = module.vpc.default_security_group_id
  description       = "Allow connections to VPC"
}

resource "aws_security_group_rule" "listener" {
  provider          = aws.datacenter
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [var.client_ip_address]
  security_group_id = module.vpc.default_security_group_id
  description       = "Allow connection from client to load balancer"
}

resource "aws_security_group_rule" "consul" {
  provider          = aws.datacenter
  type              = "ingress"
  from_port         = 8500
  to_port           = 8500
  protocol          = "tcp"
  cidr_blocks       = [var.client_ip_address]
  security_group_id = module.vpc.default_security_group_id
  description       = "Allow connection from client to Consul server"
}

resource "aws_security_group_rule" "mesh_gateway" {
  count             = var.enable_peering ? 1 : 0
  provider          = aws.datacenter
  type              = "ingress"
  from_port         = 8443
  to_port           = 8443
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.cloud.0.cidr_block]
  security_group_id = module.vpc.default_security_group_id
  description       = "Allow connection from cloud VPC to datacenter VPC"
}

resource "aws_security_group_rule" "server_gossip" {
  count             = var.enable_peering ? 1 : 0
  provider          = aws.datacenter
  type              = "ingress"
  from_port         = 8300
  to_port           = 8300
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.cloud.0.cidr_block]
  security_group_id = module.vpc.default_security_group_id
  description       = "Allow gossip from cloud VPC to datacenter VPC"
}

resource "aws_security_group_rule" "server_gossip_wan" {
  count             = var.enable_peering ? 1 : 0
  provider          = aws.datacenter
  type              = "ingress"
  from_port         = 8302
  to_port           = 8302
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.cloud.0.cidr_block]
  security_group_id = module.vpc.default_security_group_id
  description       = "Allow gossip from cloud VPC to datacenter VPC"
}