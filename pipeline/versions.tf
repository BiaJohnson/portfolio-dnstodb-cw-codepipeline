# Pipeline plumbing (CodePipeline + CodeBuild + IAM). Apply from a laptop once.
# CodeBuild only applies ../infrastructure — this root is never in that apply.
# Local state on purpose: this module *creates* the app-stack S3 backend.

terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}
