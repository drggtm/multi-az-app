output "vpc_id" {
  description = "ID of VPC"
  value       = module.networking.vpc_id
}


output "vpc_cidr_block" {
  description = "CIDR block of vpc"
  value       = module.networking.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.networking.pulic_subnets_ids
}

output "availability_zone" {
  description = "list of availability zones"
  value       = module.networking.availability_zone
}

output "internet_gateway_id" {
  description = "ID of IG"
  value       = module.networking.internet_gateway
}

output "alb_security_group_id" {
  description = "ID of ALB SG"
  value       = module.security.alb_security_group_id
}

output "ec2_security_group_id" {
  description = "sg of ec2"
  value       = module.security.ec2_security_group_id
}

output "launch_template_id" {
  description = "ID of launch template"
  value       = module.compute.launch_template_id
}

output "autoscaling_group_name" {
  description = "name of asg"
  value       = module.compute.autoscaling_group_name
}

output "target_group_arn" {
  description = "arn of target group"
  value       = module.compute.target_group_arn
}

output "load_balancer_arn" {
  description = "arn of lb"
  value       = module.compute.load_balancer_arn
}

output "load_balancer_zone_id" {
  description = "zone id of load balancer"
  value       = module.compute.load_balancer_zone_id
}

output "load_balancer_dns_name" {
  description = "Dns of load balancer"
  value       = module.compute.load_balancer_dns_name
}
