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
  key_name               = "rosemary"

  user_data = templatefile("${path.module}/templates/consul_server.tpl", {
    prometheus_url     = var.prometheus_url
    dc                 = var.datacenter
    dc_public_ip       = aws_eip.consul_server.public_ip
    consul_cert_file   = var.consul_cert_file
    consul_key_file    = var.consul_key_file
    consul_ca_file     = var.consul_ca_file
    consul_encrypt_key = var.consul_encrypt_key
    primary_gateway    = var.primary_gateway
  })

  tags = merge({ "Name" = "consul-server" }, local.tags)
}