resource "aws_sns_topic" "approval" {
  name = "${var.pipeline_name}-approval"
  tags = merge(local.tags, { Name = "${var.pipeline_name}-approval" })
}

resource "aws_sns_topic_subscription" "approval_email" {
  topic_arn = aws_sns_topic.approval.arn
  protocol  = "email"
  endpoint  = var.approval_email
}
