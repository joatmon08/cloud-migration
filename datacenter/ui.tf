# locals {
#   ui_name = "ui"
# }

# resource "aws_instance" "ui" {
#   provider      = aws.datacenter
#   ami           = data.aws_ami.ubuntu.id
#   instance_type = "t2.micro"

#   vpc_security_group_ids      = [module.vpc.default_security_group_id]
#   subnet_id                   = module.vpc.private_subnets[0]
#   associate_public_ip_address = false

#   user_data = templatefile("${path.module}/templates/app.tpl", {
#     fake_service_version = var.fake_service_version
#     description          = "${local.ui_name} (${var.datacenter})"
#     error_rate           = 0.0
#     upstream_uris        = "http://${aws_instance.app.private_ip}"
#   })

#   tags = merge({ "Name" = local.ui_name }, local.tags)
# }

# resource "aws_lb_target_group_attachment" "ui" {
#   provider         = aws.datacenter
#   target_group_arn = aws_lb_target_group.ui.arn
#   target_id        = aws_instance.ui.id
# }

# resource "aws_lb" "ui" {
#   provider           = aws.datacenter
#   name               = local.ui_name
#   internal           = false
#   load_balancer_type = "application"
#   subnets            = module.vpc.public_subnets

#   enable_deletion_protection = false

#   tags = local.tags
# }

# resource "aws_lb_target_group" "ui" {
#   provider    = aws.datacenter
#   name        = "${local.ui_name}-${var.datacenter}"
#   port        = 9090
#   protocol    = "HTTP"
#   vpc_id      = module.vpc.vpc_id
#   target_type = "instance"

#   health_check {
#     enabled = true
#     path    = "/health"
#   }
# }

# resource "aws_lb_listener" "ui" {
#   provider          = aws.datacenter
#   load_balancer_arn = aws_lb.ui.arn
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.ui.arn
#   }
# }