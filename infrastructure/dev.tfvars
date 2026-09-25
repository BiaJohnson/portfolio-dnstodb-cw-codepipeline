# Environment
environment = "dev"

# VPC Variables
vpc_name                               = "myvpc"
vpc_cidr_block                         = "10.0.0.0/16"
vpc_availability_zones                 = ["us-east-1a", "us-east-1b"]
vpc_public_subnets                     = ["10.0.101.0/24", "10.0.102.0/24"]
vpc_private_subnets                    = ["10.0.1.0/24", "10.0.2.0/24"]
vpc_database_subnets                   = ["10.0.151.0/24", "10.0.152.0/24"]
vpc_create_database_subnet_group       = true
vpc_create_database_subnet_route_table = true
vpc_enable_nat_gateway                 = true
vpc_single_nat_gateway                 = true

# EC2 Instance Variables
instance_type = "t3.micro"

# RDS Database Variables
db_name                = "webappdb"
db_instance_identifier = "webappdb"
db_username            = "dbadmin"

# App3 ASG — REPLACE with YOUR email (SNS subscription confirmation)
asg_notification_email = "you@example.com"

# REPLACE: hostname under YOUR hosted zone (must match route53_zone_name in terraform.tfvars)
dns_name = "dns-to-db-dev.example.com"
