# AWS EC2 Security Group Terraform Module
# Security Group for Private EC2 Instances
module "private_sg" {
  source = "terraform-aws-modules/security-group/aws"
  #version = "3.18.0"
  #version = "4.0.0"
  version = "5.1.0"

  name        = "${local.name}-private-sg"
  description = "App1/App2: HTTP 80 from VPC; no SSH (Session Manager on App3 only)"
  vpc_id      = module.vpc.vpc_id
  # Ingress Rules & CIDR Blocks
  ingress_rules       = ["http-80-tcp"]
  ingress_cidr_blocks = [module.vpc.vpc_cidr_block]
  # Egress Rule - all-all open
  egress_rules = ["all-all"]
  tags         = local.common_tags
}

