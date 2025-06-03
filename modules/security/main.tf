resource "aws_security_group" "alb" {
  name        = "${var.project_name}-{var.environment}-alb"
  description = "Security group of alb"
  vpc_id      = var.vpc_id
  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    description      = "HTTP to EC2 instances"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    security_groups  = [aws_security_group.ec2.id]
  }
  egress {
    description      = "All outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = merge(var.common_tags, {
    name = "${var.project_name}-${var.environment}-alb-sg"
    Type = "ALB"
  })
}

resource "aws_security_group" "ec2" {
  description = "security group for ec2"
  name        = "${var.project_name}-{var.environment}-ec2"
  vpc_id      = var.vpc_id

  ingress {
    description      = "Application port ALB"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    security_groups  = [aws_security_group.alb.id]
  }

  dynamic "ingress" {
    for_each = var.enable_ssh_access ? [1] : []
    content {
      description = "ssh access"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.ssh_cidr_blocks
    }
  }
  egress = {
    description = "for outbound traffice"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-ec2-sg"
    Type = "EC2"
  })
  lifecycle {
    create_before_destroy = true
  }
}
