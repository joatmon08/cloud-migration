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

  vpc_security_group_ids      = [module.vpc.default_security_group_id]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  key_name                    = var.key_name

  user_data = templatefile("${path.module}/templates/app.tpl", {
    fake_service_version = var.fake_service_version
    description          = "${var.application_name} (${var.datacenter})"
    error_rate           = 0.0
    upstream_uris        = ""
  })

  tags = merge({ "Name" = var.application_name }, local.tags)
}

resource "aws_lb_target_group_attachment" "app" {
  provider         = aws.datacenter
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = aws_instance.app.id
}