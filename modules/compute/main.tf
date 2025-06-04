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
  description   = "lunch template for ${var.project_name} application"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  key_name = var.key_pair_name != "" ? var.key_pair_name : null

  vpc_security_group_ids = [var.ec2_security_group_id]

  user_data = base64encode(templatefile("${path.module}/user-data.tpl", {
    app_version = var.app_version
  }))

  metadata_options {
  http_tokens                 = "required"
  http_endpoint= "enabled"
  http_put_response_hop_limit = 1
}

ebs_optimized = true

block_device_mappings {
  device_name = "/dev/xvda"
  ebs{
    volume_size = 20
    volume_type = "gp3"
    delete_on_termination = true
    encrypted = true
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
  tags = merge(var.common_tags,{
    Name = "${var.project_name}-${var.environment}-instance"
  })
}

tag_specifications {
  resource_type = "volume"
  tags = merge(var.common_tags,{
    Name="${var.project_name}-${var.environment}-volume"
  })
}

tags = merge(var.common_tags,{
  Name="${var.project_name}-${var.environment}-lunch-template"
})
lifecycle {
  create_before_destroy = true
}
}


