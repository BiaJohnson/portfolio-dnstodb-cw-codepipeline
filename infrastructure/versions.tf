# Terraform Block
terraform {
  required_version = ">= 1.6" # which means any version equal & above 0.14 like 0.15, 0.16 etc and < 1.xx
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
  # Remote state: bucket/key/lock table come from -backend-config=dev.conf or stag.conf
  backend "s3" {}
}

# Unique suffix for SNS topic names (ASG notifications)
resource "random_pet" "this" {
  length = 2
}

# Provider Block
# No `profile` — CodeBuild has no ~/.aws/credentials. Terraform uses the ambient
# credential chain: CodeBuild service role in the pipeline, or AWS_PROFILE / default
# CLI credentials on a laptop. Do not put long-lived access keys in Parameter Store.
provider "aws" {
  region = var.aws_region
}
