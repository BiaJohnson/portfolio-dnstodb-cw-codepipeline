data "aws_iam_policy_document" "codepipeline_assume" {
  statement {
    sid     = "CodePipelineAssume"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "codepipeline" {
  statement {
    sid = "ArtifactBucket"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:ListBucket",
      "s3:PutObject",
    ]
    resources = [
      aws_s3_bucket.artifacts.arn,
      "${aws_s3_bucket.artifacts.arn}/*",
    ]
  }

  statement {
    sid = "StartCodeBuild"
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]
    resources = [
      aws_codebuild_project.env["dev"].arn,
      aws_codebuild_project.env["stag"].arn,
    ]
  }

  statement {
    sid = "ApprovalSns"
    actions = [
      "sns:Publish",
    ]
    resources = [aws_sns_topic.approval.arn]
  }

  statement {
    sid = "UseGitHubConnection"
    actions = [
      "codestar-connections:UseConnection",
      "codeconnections:UseConnection",
    ]
    resources = [local.connection_arn]
  }
}

resource "aws_iam_role" "codepipeline" {
  name               = "${var.pipeline_name}-service-role"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume.json
  tags               = local.tags
}

resource "aws_iam_role_policy" "codepipeline" {
  name   = "${var.pipeline_name}-policy"
  role   = aws_iam_role.codepipeline.id
  policy = data.aws_iam_policy_document.codepipeline.json
}
