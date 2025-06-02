output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of VPC"
  value       = aws_vpc.main.cidr_block
}

output "pulic_subnets_ids" {
  description = "ID's of public subnets"
  value       = aws_subnet.public[*].id
}

output "availability_zone" {
  description = "List of availability Zones used"
  value       = local.azs
}

output "internet_gateway" {
  description = "Id of internet gateway"
  value     = aws_internet_gateway.main.id
}
