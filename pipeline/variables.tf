variable "aws_region" {
  description = "Region for the pipeline, artifact bucket, and app remote state"
  type        = string
  default     = "us-east-1"
}

variable "pipeline_name" {
  description = "CodePipeline name"
  type        = string
  default     = "tf-dnstodb-cw-cp1"
}

variable "github_full_repository_id" {
  description = "GitHub repo the pipeline clones, as owner/name (must match the CodeStar connection access)"
  type        = string
}

variable "github_branch" {
  description = "Branch that starts the pipeline"
  type        = string
  default     = "main"
}

variable "codestar_connection_name" {
  description = "Name when Terraform creates the GitHub connection (max 32 chars)"
  type        = string
  default     = "terraform-dnstodb-cw-con1"
}

variable "codestar_connection_arn" {
  description = "Existing CodeStar/CodeConnections ARN. Leave null to create a connection (complete the GitHub handshake after apply)."
  type        = string
  default     = null
}

variable "approval_email" {
  description = "Email subscribed to the pipeline approval SNS topic (confirm the subscription mail)"
  type        = string
}

variable "codebuild_timeout_minutes" {
  description = "CodeBuild timeout; stack waits on ACM, Multi-AZ RDS, ASG, and App3 bootstrap"
  type        = number
  default     = 90
}

variable "codebuild_image" {
  description = "Managed CodeBuild image (must support Python 3.9 in the buildspec)"
  type        = string
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
}

variable "codebuild_attach_administrator_access" {
  description = "Lab default: CodeBuild can terraform apply/destroy the full stack. Same idea as the course admin user, as a role instead of access keys."
  type        = bool
  default     = true
}

variable "manage_app_remote_state" {
  description = "Create the S3 bucket and DynamoDB lock tables named in infrastructure/dev.conf and stag.conf"
  type        = bool
  default     = true
}

variable "app_state_bucket_name" {
  description = "Must match bucket in infrastructure/dev.conf and stag.conf"
  type        = string
  default     = "dnstodb-cw-codepipeline-tfstate"
}

variable "app_state_lock_table_dev" {
  description = "Must match dynamodb_table in infrastructure/dev.conf"
  type        = string
  default     = "dnstodb-cw-dev-tfstate"
}

variable "app_state_lock_table_stag" {
  description = "Must match dynamodb_table in infrastructure/stag.conf"
  type        = string
  default     = "dnstodb-cw-stag-tfstate"
}

variable "app_state_bucket_force_destroy" {
  description = "Allow deleting the app state bucket while objects remain. Leave false until both env stacks are destroyed."
  type        = bool
  default     = false
}

variable "pipeline_artifact_bucket_name" {
  description = "CodePipeline artifact bucket. Empty = {account}-dnstodb-cw-cp-artifacts"
  type        = string
  default     = ""
}
