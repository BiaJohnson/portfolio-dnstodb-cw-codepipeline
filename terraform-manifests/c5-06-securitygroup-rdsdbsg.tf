# Security Group for AWS RDS DB — MySQL only from App3 SG
module "rdsdb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name        = "${local.name}-rdsdb-sg"
  description = "MySQL access from App3 security group only"
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      description              = "MySQL from App3 ASG only"
      source_security_group_id = module.app3_sg.security_group_id
    },
  ]
  egress_rules = ["all-all"]
  tags         = local.common_tags
}
