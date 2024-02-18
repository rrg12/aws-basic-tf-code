output "alb_target_group_arn" {
  value = aws_lb_target_group.alb_target_group.arn
}

output "elb_dns_name" {
  value = aws_lb.staging_alb.dns_name
}

output "elb_zone_id" {
  value = aws_lb.staging_alb.zone_id
}

