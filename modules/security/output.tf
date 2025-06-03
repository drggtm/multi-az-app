output "alb_security_group.id" {
  description = "ID of alb security group"
  value = aws_security_group.alb.id
}

output "ec2_security_group_id" {
  description = "ID of ec2 security group"
  value = aws_security_group.ec2.id
}