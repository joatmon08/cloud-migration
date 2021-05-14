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

resource "aws_security_group_rule" "ssh" {
  provider          = aws.datacenter
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.client_ip_address]
  security_group_id = module.vpc.default_security_group_id
  description       = "Allow SSH connection from client"
}

resource "aws_security_group_rule" "consul" {
  count             = var.enable_peering ? 1 : 0
  provider          = aws.datacenter
  type              = "ingress"
  from_port         = 8501
  to_port           = 8501
  protocol          = "tcp"
  cidr_blocks       = [var.client_ip_address, data.aws_vpc.cloud.0.cidr_block]
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
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpc.default_security_group_id
  description       = "Allow connection from cloud VPC to datacenter VPC"
}

resource "aws_security_group_rule" "server_gossip" {
  count             = var.enable_peering ? 1 : 0
  provider          = aws.datacenter
  type              = "ingress"
  from_port         = 9102
  to_port           = 9102
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.cloud.0.cidr_block]
  security_group_id = module.vpc.default_security_group_id
  description       = "Allow Prometheus from cloud VPC to datacenter VPC"
}