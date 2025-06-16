provider "aws" {
  region = var.aws_region
}

data "aws_availability_zone" "available" {
  state = "available"
}

module "networking" {
  source = "./modules/networking"
  vpc_cidr = var.vpc_cidr
  environment = var.environment
  project_name = var.project_name
  availability_zones_count = var.availability_zones_count
  tags= var.tags
  common_tags = var.common_tags
}

module "security" {
  source = "./modules/security"
  project_name = var.project_name
  environment = var.environment
  vpc_id = module.networking.vpc_id
  common_tags = var.common_tags
  enable_ssh_access = var.enable_ssh_access
  ssh_cidr_blocks = var.ssh_cidr_blocks
}

module "compute" {
  source = "./modules/compute"
  project_name = var.project_name
  environment = var.environment
  instance_type = var.instance_type
  key_pair_name = var.key_pair_name
  ec2_security_group_id = module.security.ec2_security_group_id
  alb_security_group_id = module.security.alb_security_group_id
  app_version = var.app_version
  common_tags = var.common_tags
  vpc_id = module.networking.vpc_id
  public_subnet_ids = module.networking.public_subnets_ids
  private_subnet_ids = var.private_subnet_ids
  min_size = var.min_size
  max_size = var.max_size
  desired_capacity = var.desired_capacity
}