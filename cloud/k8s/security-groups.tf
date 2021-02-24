resource "aws_security_group_rule" "peered_vpc_ingress" {
  provider          = aws.cloud
  type              = "ingress"
  from_port         = 30909
  to_port           = 30909
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.datacenter.cidr_block]
  security_group_id = module.eks.cluster_primary_security_group_id
  description       = "Allow inbound connections from peered VPCs"
}