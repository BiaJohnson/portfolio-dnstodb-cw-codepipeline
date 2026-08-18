# Security Group for App3 ASG (Java UMS on 8080)
# Dedicated so RDS can allow MySQL from App3 only — not App1/App2.
module "app3_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name        = "${local.name}-app3-sg"
  description = "App3 ASG: HTTP 8080 from VPC; egress open for NAT / AWS APIs"
  vpc_id      = module.vpc.vpc_id

  ingress_rules       = ["http-8080-tcp"]
  ingress_cidr_blocks = [module.vpc.vpc_cidr_block]
  egress_rules        = ["all-all"]
  tags                = local.common_tags
}
