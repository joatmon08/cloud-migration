data "aws_ami" "nomad_consul" {
  provider    = aws.datacenter
  most_recent = true

  owners = ["562637147889"]

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "is-public"
    values = ["true"]
  }

  filter {
    name   = "name"
    values = ["nomad-consul-ubuntu-*"]
  }
}

module "nomad" {
  providers = {
    aws = aws.datacenter
  }
  source       = "hashicorp/nomad/aws"
  version      = "0.7.2"
  ami_id       = data.aws_ami.nomad_consul.image_id
  cluster_name = var.datacenter
  num_clients  = 3
  num_servers  = 3
  vpc_id       = module.vpc.vpc_id
}