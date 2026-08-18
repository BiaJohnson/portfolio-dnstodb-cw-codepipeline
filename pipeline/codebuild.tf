resource "aws_codebuild_project" "env" {
  for_each = toset(["dev", "stag"])

  name                   = "codebuild-dnstodb-${each.key}"
  description            = "Terraform ${each.key} apply/destroy for DNS-to-DB + CloudWatch"
  service_role           = aws_iam_role.codebuild[each.key].arn
  build_timeout          = var.codebuild_timeout_minutes
  queued_timeout         = 480
  concurrent_build_limit = 1
  tags                   = merge(local.tags, { Env = each.key })

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = var.codebuild_image
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec-${each.key}.yml"
  }
}
