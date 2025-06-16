output "launch_template_id" {
  description = "id of luch template added/used"
  value       = aws_launch_template.main.id
}

output "autoscaling_group_name" {
  description = "Name of autoscaling group"
  value       = aws_autoscaling_group.main.name
}

output "target_group_arn" {
  description = "ARN of target group"
  value       = aws_lb_target_group.main.arn
}

output "load_balancer_arn" {
  description = "arn of load balancer"
  value       = aws_lb.main.arn
}

output "load_balancer_zone_id" {
  description = "Zone id of load balancer"
  value       = aws_lb.main.zone_id
}

output "load_balancer_dns_name" {
  description = "Dns of load balancer"
  value       = aws_lb.main.dns_name
}