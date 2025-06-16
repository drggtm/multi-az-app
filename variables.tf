variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "project_name" {
  default = "time-api"
}

variable "tags" {
  default = {
    Owner       = "team-devops"
    Environment = "dev"
  }
}
variable "availability_zones_count" {
  default = 2
  validation {
    condition     = var.availability_zones_count >= 2 && var.availability_zones_count <= 4
    error_message = "Availability zones count must be between 2 and 4."
  }
}

variable "aws_region" {
  description = "Aws region"
  type        = string
  default     = "us-east-2"
}

variable "environment" {
  description = "environment using service"
  type        = string
  default     = "dev"
}

variable "common_tags" {
  description = "tags to apply for all resourec"
  type        = map(string)
  default = {
  }
}

variable "tags" {
  description = "tags for vpc"
  type        = map(string)
  default = {

  }
}

variable "instance_type" {
  description = "type of ec2 instance"
  type        = string
  default     = "t2.micro"
}

variable "key_pair_name" {
  description = "key pair for ec2 instance creation"
  type        = string
  default     = ""
}

variable "app_version" {
  description = "version off app"
  type        = string
  default     = "1.0.0"
}

variable "min_size" {
  description = "minimu number of ec2 for autoscaling"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "maximum number of ec2 for asg"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "desired number of instance"
  type        = number
  default     = 2
}

variable "private_subnet_ids" {
  description = "Ids of private subnets for ec2"
  type        = list(string)
  default     = []
}

variable "enable_ssh_access" {
  description = "ebable ssh access to ec2?"
  type        = bool
  default     = false
}

variable "ssh_cidr_blocks" {
  description = "cidr block for ssh"
  type        = list(string)
  default     = []
}
