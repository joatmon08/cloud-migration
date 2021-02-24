resource "aws_lb" "nomad" {
  provider           = aws.datacenter
  name               = var.datacenter
  internal           = false
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false

  tags = local.tags
}

resource "aws_lb_listener" "nomad" {
  provider          = aws.datacenter
  load_balancer_arn = aws_lb.nomad.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nomad.arn
  }
}

resource "aws_lb_target_group" "nomad" {
  provider = aws.datacenter
  name     = "nomad-${var.datacenter}"
  port     = 4646
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    enabled  = true
    interval = 15
    timeout  = 5
    protocol = "HTTP"
    port     = "traffic-port"
    path     = "/v1/agent/health"
    matcher  = "200"

    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

resource "aws_autoscaling_attachment" "nomad" {
  provider               = aws.datacenter
  autoscaling_group_name = module.nomad.asg_name_servers
  alb_target_group_arn   = aws_lb_target_group.nomad.arn
}