resource "aws_eip" "consul_server" {
  provider   = aws.datacenter
  vpc        = true
  depends_on = [module.vpc]
}

resource "aws_eip_association" "consul_server" {
  provider      = aws.datacenter
  instance_id   = aws_instance.consul_server.id
  allocation_id = aws_eip.consul_server.id
}

resource "aws_instance" "consul_server" {
  provider      = aws.datacenter
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [module.vpc.default_security_group_id]
  subnet_id              = module.vpc.public_subnets[0]

  user_data = templatefile("${path.module}/templates/consul_server.tpl", {
    prometheus_url = "http://localhost:9090"
    dc             = var.datacenter
    dc_public_ip   = aws_eip.consul_server.public_ip
  })

  tags = merge({ "Name" = var.application_name }, local.tags)
}