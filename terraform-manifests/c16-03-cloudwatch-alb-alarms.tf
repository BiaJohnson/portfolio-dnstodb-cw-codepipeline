# -----------------------------------------------------------------------------
# CloudWatch — ALB HTTP error alarms (notify-only via App3 SNS)
# 4xx = target client errors; ELB 5xx = load balancer failed the request
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "alb_4xx_errors" {
  alarm_name          = "${local.name}-ALB-HTTP-4xx-errors"
  comparison_operator = "GreaterThanThreshold"
  datapoints_to_alarm = "2"
  evaluation_periods  = "3"
  metric_name         = "HTTPCode_Target_4XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "120"
  statistic           = "Sum"
  threshold           = "5"
  treat_missing_data  = "missing"

  dimensions = {
    LoadBalancer = module.alb.arn_suffix
  }

  alarm_description = "Monitors ALB target HTTP 4xx count; notifies SNS when sum exceeds threshold for 2 of 3 evaluation periods."

  ok_actions    = [aws_sns_topic.app3_asg.arn]
  alarm_actions = [aws_sns_topic.app3_asg.arn]
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx_errors" {
  alarm_name          = "${local.name}-ALB-HTTP-ELB-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  datapoints_to_alarm = "2"
  evaluation_periods  = "3"
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "120"
  statistic           = "Sum"
  threshold           = "5"
  treat_missing_data  = "missing"

  dimensions = {
    LoadBalancer = module.alb.arn_suffix
  }

  alarm_description = "Monitors ALB-generated HTTP 5xx count; notifies SNS when sum exceeds threshold for 2 of 3 evaluation periods (availability signal)."

  ok_actions    = [aws_sns_topic.app3_asg.arn]
  alarm_actions = [aws_sns_topic.app3_asg.arn]
}
