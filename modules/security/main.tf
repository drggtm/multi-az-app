resource "aws_security_group" "alb" {
  name        = "${var.project_name}-{var.environment}-alb"
  description = "Security group of alb"
  vpc_id      = var.vpc_id
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}