output "listener_arn" {
  value = aws_lb_listener.app.arn
}

output "blue_target_group_arn" {
  value = aws_lb_target_group.app.arn
}

output "vpc_id" {
  value = module.vpc.vpc_id
}