resource "aws_security_group_rule" "load_balancer" {
  provider          = aws.datacenter
  type              = "ingress"
  from_port         = 4646
  to_port           = 4646
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