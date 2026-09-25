# -----------------------------------------------------------------------------
# Phase B — IAM role + instance profile for App3 EC2
# - AmazonSSMManagedInstanceCore: Session Manager (Phase C) + SSM agent
# - Inline policy: read only /<env>/app3/db/* parameters at boot
# -----------------------------------------------------------------------------

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

resource "aws_iam_role" "app3" {
  name = "${local.name}-app3-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "app3_ssm_managed_instance_core" {
  role       = aws_iam_role.app3.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "app3_ssm_db_parameters" {
  name = "${local.name}-app3-ssm-db-params"
  role = aws_iam_role.app3.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ReadApp3DbParameters"
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]
        Resource = "arn:${data.aws_partition.current.partition}:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/${var.environment}/app3/db/*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "app3" {
  name = "${local.name}-app3-ec2-profile"
  role = aws_iam_role.app3.name
  tags = local.common_tags
}
