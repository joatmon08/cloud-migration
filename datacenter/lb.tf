# resource "aws_lb" "app" {
#   provider           = aws.datacenter
#   name               = var.application_name
#   internal           = true
#   load_balancer_type = "application"
#   subnets            = module.vpc.public_subnets

#   enable_deletion_protection = false

#   tags = local.tags
# }

# resource "aws_lb_target_group" "app" {
#   provider    = aws.datacenter
#   name        = "${var.application_name}-${var.datacenter}"
#   port        = 9090
#   protocol    = "HTTP"
#   vpc_id      = module.vpc.vpc_id
#   target_type = "instance"

#   health_check {
#     enabled = true
#     path    = "/health"
#   }
# }

# resource "aws_lb_listener" "app" {
#   provider          = aws.datacenter
#   load_balancer_arn = aws_lb.app.arn
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.app.arn
#   }
# }