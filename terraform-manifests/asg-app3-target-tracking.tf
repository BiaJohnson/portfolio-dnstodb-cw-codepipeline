# -----------------------------------------------------------------------------
# Phase 9 — Target tracking scaling policies for App3 ASG
# -----------------------------------------------------------------------------

resource "aws_autoscaling_policy" "app3_avg_cpu" {
  name                      = "${local.name}-app3-avg-cpu"
  policy_type               = "TargetTrackingScaling"
  autoscaling_group_name    = aws_autoscaling_group.app3.name
  estimated_instance_warmup = 180

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.app3_asg_cpu_target
  }
}

resource "aws_autoscaling_policy" "app3_alb_request_count" {
  name                      = "${local.name}-app3-alb-requests"
  policy_type               = "TargetTrackingScaling"
  autoscaling_group_name    = aws_autoscaling_group.app3.name
  estimated_instance_warmup = 180

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${module.alb.arn_suffix}/${module.alb.target_groups["mytg3"].arn_suffix}"
    }
    target_value = var.app3_asg_request_count_target
  }
}
