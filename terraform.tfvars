aws_region   = "us-west-2"
project_name = "time-api"
environment  = "dev"

common_tags = {
  project     = "time-api"
  environment = "dev"
  owner       = "devOps team"
  managedby   = "terraform"
}

vpc_cidr                 = "10.0.0.0/16"
availability_zones_count = 2

tags = {
  Name = "time-api"
}

enable_ssh_access = true
ssh_cidr_blocks   = ["0.0.0.0/0"]

instance_type      = "t2.micro"
key_pair_name      = "ec2-key-pair"
app_version        = "1.0.0"
min_size           = 1
max_size           = 3
desired_capacity   = 2
private_subnet_ids = []
