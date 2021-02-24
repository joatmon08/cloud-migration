output "vpc_id" {
  value = module.vpc.vpc_id
}

output "listener_arn" {
  value = aws_lb_listener.nomad.arn
}

output "blue_target_group_arn" {
  value = aws_lb_target_group.nomad.arn
}

output "nomad_endpoint" {
  value = aws_lb.nomad.dns_name
}