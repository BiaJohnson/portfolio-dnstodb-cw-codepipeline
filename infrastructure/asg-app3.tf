# -----------------------------------------------------------------------------
# Phase 8 — Auto Scaling Group for App3 → existing ALB target group mytg3
# Path rule /* stays unchanged; ASG owns TG registration.
# -----------------------------------------------------------------------------

resource "aws_autoscaling_group" "app3" {
  name_prefix         = "${local.name}-app3-asg-"
  desired_capacity    = var.app3_asg_desired_capacity
  min_size            = var.app3_asg_min_size
  max_size            = var.app3_asg_max_size
  vpc_zone_identifier = module.vpc.private_subnets

  target_group_arns = [module.alb.target_groups["mytg3"].arn]

  health_check_type         = "ELB"
  health_check_grace_period = var.app3_asg_health_check_grace_period

  launch_template {
    id      = aws_launch_template.app3.id
    version = aws_launch_template.app3.latest_version
  }

  # Phase 9 — rolling refresh when LT / capacity-related attrs change
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["desired_capacity"]
  }

  tag {
    key                 = "Name"
    value               = "${local.name}-app3"
    propagate_at_launch = true
  }

  tag {
    key                 = "owners"
    value               = local.owners
    propagate_at_launch = true
  }

  tag {
    key                 = "environment"
    value               = local.environment
    propagate_at_launch = true
  }

  depends_on = [
    aws_ssm_parameter.app3_db_username,
    aws_ssm_parameter.app3_db_password,
    aws_ssm_parameter.app3_db_name,
    aws_ssm_parameter.app3_db_port,
    module.rdsdb,
    data.aws_iam_role.autoscaling,
  ]
}
