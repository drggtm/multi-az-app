variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "project_name" {
  default = "time-api"
}

variable "tags" {
  default = {
    Owner = "team-devops"
    Environment= "dev"
  }
}
variable "availability_zones_count" {
  default = 2
    validation {
    condition     = var.availability_zones_count >= 2 && var.availability_zones_count <= 4
    error_message = "Availability zones count must be between 2 and 4."
  }
}