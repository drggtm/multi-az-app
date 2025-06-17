data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-X86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_launch_template" "main" {
  name_prefix   = "${var.project_name}-${var.environment}"
  description   = "launch template for ${var.project_name} application"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  key_name = var.key_pair_name != "" ? var.key_pair_name : null

  vpc_security_group_ids = [var.ec2_security_group_id]

  user_data = base64encode(templatefile("${path.module}/user-data.tpl", {
    app_version = var.app_version
  }))

  metadata_options {
    http_tokens                 = "required"
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
  }

  ebs_optimized = true

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }

  monitoring {
    enabled = true
  }
  network_interfaces {
    associate_public_ip_address = false
  }
  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, {
      Name = "${var.project_name}-${var.environment}-instance"
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(var.common_tags, {
      Name = "${var.project_name}-${var.environment}-volume"
    })
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-launch-template"
  })
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "main" {
  name_prefix = "${substr(var.project_name, 0, 6)}-"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/health"
    matcher             = "200"
    port                = "traffic-port"
    protocol            = "HTTP"
  }
  deregistration_delay = 30

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-target-group"
  })
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb" "main" {
  name                       = "${var.project_name}-${var.environment}-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [var.alb_security_group_id]
  subnets                    = var.public_subnet_ids
  enable_deletion_protection = false
  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-alb"
  })
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-albllistener"
  })
}

resource "aws_autoscaling_group" "main" {
  name                = "${var.project_name}-${var.environment}-asg"
  vpc_zone_identifier = var.public_subnet_ids
  target_group_arns = [aws_lb_target_group.main.arn]
  health_check_type = "ELB"
  health_check_grace_period = 300
  min_size = var.min_size
  max_size = var.max_size
  desired_capacity = var.desired_capacity

    launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
}
instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
}
dynamic "tag" {
    for_each = var.common_tags
    content {
      key                 = tag.key
      propagate_at_launch = true
      value               = tag.value
}
}
  tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.environment}-asg-instance"
    propagate_at_launch = true
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "upscale" {
  name                   = "${var.project_name}-${var.environment}-upscale"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.main.name
}

resource "aws_autoscaling_policy" "downscale" {
  name                   = "${var.project_name}-${var.environment}-downscale"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.main.name
}

resource "aws_cloudwatch_metric_alarm" "high-cpu" {
  alarm_name          =  "${var.project_name}-${var.environment}-high-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.upscale.arn]
  
  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "low-cpu" {
  alarm_name          =  "${var.project_name}-${var.environment}-low-cpu"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 20

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.downscale.arn]
  
  tags = var.common_tags
}