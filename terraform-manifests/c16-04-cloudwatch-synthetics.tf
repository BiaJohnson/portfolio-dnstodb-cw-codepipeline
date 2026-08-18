# -----------------------------------------------------------------------------
# CloudWatch Synthetics — IAM + S3 + canary + SuccessPercent alarm
# Adapted from lesson 17 c14-05; canary URL = portfolio DNS (c12) by default.
# -----------------------------------------------------------------------------

locals {
  # Unique per env in the same account/region; handler + zip filename must match.
  canary_name = "${var.environment}-dnstodb"
  canary_url = (
    var.canary_url != null
    ? var.canary_url
    : "https://${trimsuffix(aws_route53_record.apps_dns.fqdn, ".")}/"
  )
}

# --- IAM: canary execution role (Lambda) -------------------------------------

resource "aws_iam_policy" "cw_canary" {
  name        = "${local.name}-cw-canary-policy"
  path        = "/"
  description = "CloudWatch Synthetics canary: metrics, logs, S3 artifacts, X-Ray"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "PutSyntheticsMetrics"
        Effect   = "Allow"
        Action   = "cloudwatch:PutMetricData"
        Resource = "*"
        Condition = {
          StringEquals = {
            "cloudwatch:namespace" = "CloudWatchSynthetics"
          }
        }
      },
      {
        Sid    = "CanaryRuntime"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetBucketLocation",
          "s3:ListAllMyBuckets",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "xray:PutTraceSegments"
        ]
        Resource = "*"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role" "cw_canary" {
  name        = "${local.name}-cw-canary-role"
  description = "CloudWatch Synthetics Lambda execution role for portfolio canary"
  path        = "/service-role/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "cw_canary" {
  role       = aws_iam_role.cw_canary.name
  policy_arn = aws_iam_policy.cw_canary.arn
}

# --- S3: canary run artifacts ------------------------------------------------

resource "aws_s3_bucket" "cw_canary" {
  bucket        = "${local.name}-cw-canary-${random_pet.this.id}"
  force_destroy = true

  tags = merge(local.common_tags, {
    Name = "${local.name}-cw-canary"
  })
}

resource "aws_s3_bucket_ownership_controls" "cw_canary" {
  bucket = aws_s3_bucket.cw_canary.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "cw_canary" {
  depends_on = [aws_s3_bucket_ownership_controls.cw_canary]
  bucket     = aws_s3_bucket.cw_canary.id
  acl        = "private"
}

resource "aws_s3_bucket_public_access_block" "cw_canary" {
  bucket = aws_s3_bucket.cw_canary.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# --- Canary script zip (URL injected from portfolio DNS) ---------------------

data "archive_file" "cw_canary" {
  type        = "zip"
  output_path = "${path.module}/canary/${local.canary_name}.zip"

  source {
    content = templatefile("${path.module}/canary/dnstodb.js.tftpl", {
      canary_url = local.canary_url
    })
    filename = "nodejs/node_modules/${local.canary_name}.js"
  }
}

resource "aws_synthetics_canary" "dnstodb" {
  name                 = local.canary_name
  artifact_s3_location = "s3://${aws_s3_bucket.cw_canary.id}/${local.canary_name}"
  execution_role_arn   = aws_iam_role.cw_canary.arn
  handler              = "${local.canary_name}.handler"
  zip_file             = data.archive_file.cw_canary.output_path
  runtime_version      = "syn-nodejs-puppeteer-9.1"
  start_canary         = true

  run_config {
    active_tracing     = true
    memory_in_mb       = 960
    timeout_in_seconds = 60
  }

  schedule {
    expression = var.canary_schedule_expression
  }

  tags = local.common_tags

  depends_on = [
    aws_iam_role_policy_attachment.cw_canary,
    aws_s3_bucket_acl.cw_canary,
    aws_s3_bucket_public_access_block.cw_canary,
  ]
}

# --- Alarm: SuccessPercent below threshold → App3 SNS ------------------------

resource "aws_cloudwatch_metric_alarm" "synthetics_success_percent" {
  alarm_name          = "${local.name}-Synthetics-SuccessPercent"
  comparison_operator = "LessThanThreshold"
  datapoints_to_alarm = 1
  evaluation_periods  = 1
  metric_name         = "SuccessPercent"
  namespace           = "CloudWatchSynthetics"
  period              = 300
  statistic           = "Average"
  threshold           = var.canary_success_percent_threshold
  treat_missing_data  = "breaching"

  dimensions = {
    CanaryName = aws_synthetics_canary.dnstodb.id
  }

  alarm_description = "Synthetics canary SuccessPercent below ${var.canary_success_percent_threshold}% for ${local.canary_url}"

  ok_actions    = [aws_sns_topic.app3_asg.arn]
  alarm_actions = [aws_sns_topic.app3_asg.arn]
}
