variable "project_name" {
  description = "Name of project"
  type        = string
}

variable "environment" {
  description = "Name of env"
  type        = string
}

variable "instance_type" {
  description = "type of ec2 instance"
  type        = string

}

variable "key_pair_name" {
  description = "Key-pair for ec2 instance setup"
  type        = string
}

variable "ec2_security_group_id" {
  description = "ID of ec2 security group"
  type        = string
}

variable "app_version" {
  description = "veersion of application"
  type        = string
  default     = "1.0.0"
}

variable "common_tags" {
  description = "Tags that can be applied to all resource"
  type        = map(string)
}

variable "vpc_id" {
  description = "Id of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "PUblic subnet ID"
  type        = list(string)
}

variable "min_size" {
  description = "minimum number of instance in asg"
  type        = number
}

variable "max_size" {
  description = "max number of instances in asg"
  type        = number
}

variable "desired_capacity" {
  description = "Desired number of instance"
  type        = number
}

variable "alb_security_group_id" {
  description = "ID of alb security group"
  type = string
}