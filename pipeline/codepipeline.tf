resource "aws_codepipeline" "this" {
  name           = var.pipeline_name
  pipeline_type  = "V2"
  execution_mode = "QUEUED"
  role_arn       = aws_iam_role.codepipeline.arn
  tags           = local.tags

  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        ConnectionArn        = local.connection_arn
        FullRepositoryId     = var.github_full_repository_id
        BranchName           = var.github_branch
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  stage {
    name = "Dev-Deploy"

    action {
      name            = "Dev-Deploy"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceArtifact"]

      configuration = {
        ProjectName = aws_codebuild_project.env["dev"].name
      }
    }
  }

  stage {
    name = "Email-Approval"

    action {
      name     = "Email-Approval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"

      configuration = {
        NotificationArn = aws_sns_topic.approval.arn
        CustomData      = "Approve to deploy to staging"
      }
    }
  }

  stage {
    name = "Stage-Deploy"

    action {
      name            = "Stage-Deploy"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceArtifact"]

      configuration = {
        ProjectName = aws_codebuild_project.env["stag"].name
      }
    }
  }

  depends_on = [
    aws_iam_role_policy.codepipeline,
    aws_iam_role_policy.codebuild_ssm,
    aws_iam_role_policy_attachment.codebuild_admin,
  ]
}
