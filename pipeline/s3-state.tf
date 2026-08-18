# App-stack remote state (names must match terraform-manifests/dev.conf and stag.conf).
# Destroy the env stacks through the pipeline first, then destroy this root.

resource "aws_s3_bucket" "app_state" {
  count = var.manage_app_remote_state ? 1 : 0

  bucket        = var.app_state_bucket_name
  force_destroy = var.app_state_bucket_force_destroy
  tags          = merge(local.tags, { Name = var.app_state_bucket_name })
}

resource "aws_s3_bucket_versioning" "app_state" {
  count  = var.manage_app_remote_state ? 1 : 0
  bucket = aws_s3_bucket.app_state[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "app_state" {
  count  = var.manage_app_remote_state ? 1 : 0
  bucket = aws_s3_bucket.app_state[0].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "app_state" {
  count  = var.manage_app_remote_state ? 1 : 0
  bucket = aws_s3_bucket.app_state[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "app_state_lock_dev" {
  count = var.manage_app_remote_state ? 1 : 0

  name         = var.app_state_lock_table_dev
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(local.tags, { Name = var.app_state_lock_table_dev })
}

resource "aws_dynamodb_table" "app_state_lock_stag" {
  count = var.manage_app_remote_state ? 1 : 0

  name         = var.app_state_lock_table_stag
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(local.tags, { Name = var.app_state_lock_table_stag })
}
