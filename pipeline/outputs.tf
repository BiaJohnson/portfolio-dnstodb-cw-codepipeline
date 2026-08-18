output "pipeline_name" {
  description = "CodePipeline name"
  value       = aws_codepipeline.this.name
}

output "pipeline_console_url" {
  description = "Console URL for this pipeline"
  value       = "https://${data.aws_region.current.region}.console.aws.amazon.com/codesuite/codepipeline/pipelines/${aws_codepipeline.this.name}/view"
}

output "codestar_connection_arn" {
  description = "GitHub connection used by Source"
  value       = local.connection_arn
}

output "codestar_connection_status" {
  description = "PENDING until you complete the GitHub handshake in the console; then AVAILABLE"
  value       = var.codestar_connection_arn == null ? aws_codestarconnections_connection.github[0].connection_status : "using existing ARN (status not read)"
}

output "codestar_connection_console_url" {
  description = "Complete the GitHub connection here if Terraform created it"
  value       = "https://${data.aws_region.current.region}.console.aws.amazon.com/codesuite/settings/connections"
}

output "codebuild_project_names" {
  value = {
    dev  = aws_codebuild_project.env["dev"].name
    stag = aws_codebuild_project.env["stag"].name
  }
}

output "approval_sns_topic_arn" {
  value = aws_sns_topic.approval.arn
}

output "approval_email" {
  description = "Confirm the SNS subscription mailed to this address before the first approval"
  value       = var.approval_email
}

output "artifact_bucket" {
  value = aws_s3_bucket.artifacts.bucket
}

output "app_state_bucket" {
  value = var.manage_app_remote_state ? aws_s3_bucket.app_state[0].id : "not managed (manage_app_remote_state=false)"
}

output "next_steps" {
  value = <<-EOT
    1. Confirm the SNS email for pipeline approval.
    2. If connection status is PENDING: open the connections URL, Connect to GitHub, grant this repo only.
    3. Put /CodeBuild/DB_PASSWORD and /CodeBuild/APP3_DB_PASSWORD in Parameter Store (not created here).
    4. Push this folder to GitHub ${var.github_full_repository_id} branch ${var.github_branch}.
    5. CodePipeline → Release change if the first run started before the connection was AVAILABLE.
  EOT
}
