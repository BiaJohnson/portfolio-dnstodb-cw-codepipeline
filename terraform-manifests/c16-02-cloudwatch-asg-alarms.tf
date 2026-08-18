# -----------------------------------------------------------------------------
# CloudWatch — App3 ASG CPU alarm (notify-only)
# Portfolio already scales via TTSP (c15-05); do not attach a step scaling policy.
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "app3_asg_cwa_cpu" {
  alarm_name          = "${local.name}-App3-ASG-CWA-CPUUtilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app3.name
  }

  alarm_description = "Monitors App3 ASG EC2 CPU utilization; notifies SNS when average CPU is at or above 80% (scaling remains TTSP-only)."

  ok_actions    = [aws_sns_topic.app3_asg.arn]
  alarm_actions = [aws_sns_topic.app3_asg.arn]
}
