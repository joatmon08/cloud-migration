resource "aws_lb" "app" {
  provider           = aws.datacenter
  name               = var.application_name
  internal           = false
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false

  tags = local.tags
}

resource "aws_lb_target_group" "nomad" {
  provider = aws.datacenter
  name     = "nomad-${var.datacenter}"
  port     = 4646
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    enabled = true
    path    = "/ui"
  }
}

resource "aws_autoscaling_attachment" "nomad" {
  provider               = aws.datacenter
  autoscaling_group_name = module.nomad.asg_name_servers
  alb_target_group_arn   = aws_lb_target_group.nomad.arn
}