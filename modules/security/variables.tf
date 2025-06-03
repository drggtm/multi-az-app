variable "project_name" {
  description = "name of project"
  type = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type = string
}

variable "common_tags" {
  description = "common tags to apply to all resources"
  type = map(string)
}

variable "environment" {
  description = "Environment name"
  type = string
}

variable "enable_ssh_access" {
  description = "ssh access to ec2"
  type = bool
  default = false
}

variable "ssh_cidr_blocks" {
  description = "cidr for ssh access"
  type = list(string)
  default = [ ]
}