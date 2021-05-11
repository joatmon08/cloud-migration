data "aws_ami" "ubuntu" {
  provider    = aws.datacenter
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "app" {
  provider      = aws.datacenter
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = "rosemary"

  vpc_security_group_ids      = [module.vpc.default_security_group_id]
  subnet_id                   = module.vpc.private_subnets[0]
  associate_public_ip_address = false

  user_data = templatefile("${path.module}/templates/app.tpl", {
    fake_service_version = var.fake_service_version
    description          = "${var.application_name} (${var.datacenter})"
    error_rate           = 0.0
    upstream             = ""
    upstream_uris        = ""
    app_name             = var.application_name
    dc                   = var.datacenter
    consul_http_addr     = aws_instance.consul_server.private_ip
    consul_ca_file       = var.consul_ca_file
    consul_encrypt_key   = var.consul_encrypt_key
  })

  tags = merge({ "Name" = var.application_name }, local.tags)
}