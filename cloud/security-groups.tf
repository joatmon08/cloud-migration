resource "aws_security_group_rule" "peered_vpc_ingress" {
  provider          = aws.cloud
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.eks.cluster_primary_security_group_id
  description       = "Allow inbound connections from peered VPCs"
}