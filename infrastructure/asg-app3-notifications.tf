# -----------------------------------------------------------------------------
# Phase 9 — ASG SNS notifications (launch / terminate / errors)
# Confirm the email subscription in your inbox after first apply.
# -----------------------------------------------------------------------------

resource "aws_sns_topic" "app3_asg" {
  name = "${local.name}-app3-asg-${random_pet.this.id}"
  tags = local.common_tags
}

resource "aws_sns_topic_subscription" "app3_asg_email" {
  topic_arn = aws_sns_topic.app3_asg.arn
  protocol  = "email"
  endpoint  = var.asg_notification_email
}

resource "aws_autoscaling_notification" "app3_asg" {
  group_names = [aws_autoscaling_group.app3.name]
  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]
  topic_arn = aws_sns_topic.app3_asg.arn
}
