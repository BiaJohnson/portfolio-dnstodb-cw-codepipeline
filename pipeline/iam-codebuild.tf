data "aws_iam_policy_document" "codebuild_assume" {
  statement {
    sid     = "CodeBuildAssume"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "codebuild_ssm" {
  statement {
    sid = "GetCodeBuildDbPasswords"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
    ]
    resources = local.ssm_parameter_arns
  }
}

resource "aws_iam_role" "codebuild" {
  for_each = toset(["dev", "stag"])

  name               = "codebuild-dnstodb-${each.key}-service-role"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume.json
  tags               = merge(local.tags, { Env = each.key })
}

resource "aws_iam_role_policy" "codebuild_ssm" {
  for_each = aws_iam_role.codebuild

  name   = "codebuild-dnstodb-ssm-getparameters"
  role   = each.value.id
  policy = data.aws_iam_policy_document.codebuild_ssm.json
}

# Lab: same blast radius as the course admin user, without long-lived access keys.
resource "aws_iam_role_policy_attachment" "codebuild_admin" {
  for_each = {
    for k, v in aws_iam_role.codebuild : k => v
    if var.codebuild_attach_administrator_access
  }

  role       = each.value.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role_policy" "codebuild_bootstrap" {
  for_each = {
    for k, v in aws_iam_role.codebuild : k => v
    if !var.codebuild_attach_administrator_access
  }

  name = "codebuild-dnstodb-app3-bootstrap"
  role = each.value.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "App3Bootstrap"
        Effect = "Allow"
        Action = [
          "ssm:SendCommand",
          "ssm:GetCommandInvocation",
          "ssm:DescribeInstanceInformation",
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:StartInstanceRefresh",
        ]
        Resource = "*"
      },
      {
        Sid    = "CodeBuildLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Resource = "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/*"
      },
    ]
  })
}
