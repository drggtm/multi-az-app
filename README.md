# Time API Infrastructure

A complete AWS infrastructure setup using Terraform to deploy a scalable Time API application with Auto Scaling, Load Balancing, and monitoring capabilities.

## 🏗️ Architecture Overview

This infrastructure creates a robust, scalable web application deployment on AWS with the following components:

- **Application Load Balancer (ALB)** - Distributes traffic across multiple EC2 instances
- **Auto Scaling Group (ASG)** - Automatically scales EC2 instances based on CPU utilization
- **EC2 Instances** - Runs a Python-based Time API service
- **VPC with Public Subnets** - Network isolation across multiple Availability Zones
- **Security Groups** - Controls inbound/outbound traffic
- **CloudWatch Alarms** - Monitors CPU utilization and triggers scaling events

```
Internet
    ↓
Application Load Balancer (Public Subnets)
    ↓
Auto Scaling Group
    ↓
EC2 Instances (Public Subnets) - Python Time API
    ↓
CloudWatch Monitoring & Alarms
```

## 📁 Project Structure

```
.
├── main.tf                 # Root module - orchestrates all components
├── variables.tf            # Root module variables
├── outputs.tf             # Root module outputs
├── terraform.tfvars       # Variable values
├── versions.tf            # Terraform and provider version constraints
├── README.md              # This file
└── modules/
    ├── networking/        # VPC, subnets, internet gateway
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── security/          # Security groups for ALB and EC2
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── compute/           # Launch template, ASG, ALB, scaling policies
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        └── user-data.tpl  # EC2 initialization script
```

## 🚀 Time API Application

The deployed application provides a simple REST API with the following endpoints:

- `GET /` or `GET /time` - Returns current time with instance metadata
- `GET /health` - Health check endpoint (used by ALB)
- `GET /metrics` - Basic system metrics (CPU, memory, disk usage)

### Sample Response
```json
{
  "current_time": "2025-06-17T10:30:45.123456",
  "timezone": "UTC",
  "instance_id": "i-0123456789abcdef0",
  "availability_zone": "us-west-2a",
  "hostname": "ip-10-0-1-123",
  "status": "healthy",
  "version": "1.0.0"
}
```

## 📋 Prerequisites

### Required Tools
- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- An AWS account with appropriate permissions

### AWS Permissions Required
Your AWS credentials need the following permissions:
- EC2 (instances, security groups, key pairs)
- VPC (vpc, subnets, internet gateways, route tables)
- Elastic Load Balancing (load balancers, target groups)
- Auto Scaling (launch templates, auto scaling groups, policies)
- CloudWatch (alarms)
- IAM (for EC2 instance profiles - if using)

### AWS Key Pair (Optional)
If you want SSH access to instances:
```bash

aws ec2 create-key-pair --key-name ec2-key-pair --query 'KeyMaterial' --output text > ec2-key-pair.pem
chmod 400 ec2-key-pair.pem
```

## ⚙️ Configuration

### 1. Update terraform.tfvars
Customize the configuration according to your needs:

```hcl
# Basic Configuration
aws_region   = "us-west-2"           # Change to your preferred region
project_name = "time-api"
environment  = "dev"

# Resource Tags
common_tags = {
  project     = "time-api"
  environment = "dev"
  owner       = "devops-team"         # Update with your team
  managedby   = "terraform"
}

# Network Configuration
vpc_cidr                 = "10.0.0.0/16"
availability_zones_count = 2          # Use 2 AZs for high availability

# Security Configuration
enable_ssh_access = true              # Set to false if SSH not needed
ssh_cidr_blocks   = ["0.0.0.0/0"]    # Restrict to your IP for better security

# EC2 Configuration
instance_type      = "t2.micro"       # Free tier eligible
key_pair_name      = "ec2-key-pair"   # Your AWS key pair name
app_version        = "1.0.0"

# Auto Scaling Configuration
min_size           = 1
max_size           = 3
desired_capacity   = 2
```

### 2. Regional Configuration
Update the AWS region in both `terraform.tfvars` and `variables.tf` if needed.

## 🚀 Deployment Instructions

### 1. Initialize Terraform
```bash
terraform init
```

### 2. Validate Configuration
```bash
terraform validate
terraform fmt
```

### 3. Plan Deployment
```bash
terraform plan
```
Review the plan output to ensure all resources will be created as expected.

### 4. Deploy Infrastructure
```bash
terraform apply
```
Type `yes` when prompted to confirm the deployment.

### 5. Get Application URL
After deployment, get the load balancer DNS name:
```bash
terraform output load_balancer_dns_name
```

## 🧪 Testing the Application

### 1. Test the Time API
```bash

ALB_DNS=$(terraform output -raw load_balancer_dns_name)


curl http://$ALB_DNS/time


curl http://$ALB_DNS/health


curl http://$ALB_DNS/metrics
```

### 2. Test Auto Scaling
Generate load to trigger scaling:
```bash
while true; do curl http://$ALB_DNS/time; sleep 0.1; done
```

Monitor the Auto Scaling Group in AWS Console to see new instances being launched when CPU > 80%.

### 3. SSH Access (if enabled)
```bash

ssh -i ec2-key-pair.pem ec2-user@<instance-public-ip>
```

## 📊 Monitoring and Logs

### CloudWatch Alarms
The infrastructure creates the following CloudWatch alarms:
- **High CPU Alarm** - Triggers scale-up when CPU > 80% for 4 minutes
- **Low CPU Alarm** - Triggers scale-down when CPU < 20% for 4 minutes

### Application Logs
View application logs on EC2 instances:
```bash

sudo journalctl -u time-api -f
```

### Load Balancer Health Checks
Monitor target group health in AWS Console:
- EC2 → Load Balancers → Target Groups → Select your target group → Targets tab

## 🧹 Cleanup

**Important**: Always destroy resources after testing to avoid unnecessary charges.

### Destroy Infrastructure
```bash
terraform destroy
```
Type `yes` when prompted to confirm the destruction.

### Verify Cleanup
Check AWS Console to ensure all resources are deleted:
- EC2 instances
- Load balancer
- Target groups
- Auto Scaling Group
- VPC and related networking components

## 💰 Cost Considerations

### Free Tier Resources
- **EC2 t2.micro**: 750 hours/month (first 12 months)
- **Application Load Balancer**: 750 hours/month (first 12 months)
- **EBS gp3 storage**: 30 GB/month
- **Data transfer**: 100 GB/month

### Potential Charges (for testing)
- **Multiple instances**: Exceeds 750 free hours (≈$0.0116/hour per additional instance)
- **Cross-AZ data transfer**: Minimal for short testing
- **Estimated cost for few hours of testing**: $1-5

### Cost Optimization Tips
1. Use `desired_capacity = 1` for minimal cost
2. Use single AZ (`availability_zones_count = 1`) to reduce data transfer
3. Always run `terraform destroy` after testing

## 🔧 Customization

### Modify Instance Type
```hcl
# In terraform.tfvars
instance_type = "t3.small"  # Upgrade from t2.micro
```

### Add HTTPS Support
Add SSL certificate and HTTPS listener to the ALB configuration in `modules/compute/main.tf`.

### Enable Private Subnets
To use private subnets with NAT Gateway (additional cost):
1. Modify `modules/networking/main.tf` to add private subnets
2. Add NAT Gateway configuration
3. Update route tables for private subnets
4. Modify compute module to use private subnets

### Customize Application
Modify `modules/compute/user-data.tpl` to:
- Install different applications
- Change application ports
- Add additional services
- Configure custom monitoring

## 🔍 Troubleshooting

### Common Issues

#### 1. Auto Scaling Group Creation Failed
**Error**: `InvalidSubnet` or subnet-related errors
**Solution**: Ensure networking module outputs are correctly referenced

#### 2. Load Balancer Target Registration Failed
**Error**: Targets show as "unhealthy"
**Solutions**:
- Check security group allows ALB to reach EC2 instances on port 8080
- Verify application is running and responding on `/health` endpoint
- Check CloudWatch logs for application errors

#### 3. Cannot Access Application
**Error**: Connection timeout or refused
**Solutions**:
- Verify ALB security group allows inbound traffic on port 80
- Check that ALB is internet-facing
- Ensure DNS propagation is complete

#### 4. SSH Access Issues
**Error**: Permission denied or connection refused
**Solutions**:
- Verify key pair exists in the specified region
- Check security group allows SSH (port 22) from your IP
- Ensure `enable_ssh_access = true` in configuration

### Debug Commands
```bash
# Check Terraform state
terraform state list
terraform state show <resource_name>

# Validate configuration
terraform validate

# Check AWS resources
aws ec2 describe-instances --region us-west-2
aws elbv2 describe-load-balancers --region us-west-2
```

**⚠️ Remember**: Always run `terraform destroy` after testing to avoid unnecessary AWS charges!