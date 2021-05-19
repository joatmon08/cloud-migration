output "listener_arn" {
  value = aws_lb_listener.app.arn
}

output "blue_target_group_arn" {
  value = aws_lb_target_group.app.arn
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}

output "alb_dns_name" {
  value = aws_lb.app.dns_name
}