variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "tags" {
  description = "tags to apply to the vpc"
  type        = map(string)
}

variable "project_name" {
  description = "name of project"
  type        = string
}

variable "environment" {
  description = "name of env"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resource"
  type = map(string)
}

variable "availability_zones_count" {
  description = "Number of availability zones to use"
  type = number
}