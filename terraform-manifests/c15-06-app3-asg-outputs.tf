# -----------------------------------------------------------------------------
# Phase 7–9 — App3 Launch Template + ASG outputs
# -----------------------------------------------------------------------------

output "app3_launch_template_id" {
  description = "App3 Launch Template ID"
  value       = aws_launch_template.app3.id
}

output "app3_launch_template_latest_version" {
  description = "App3 Launch Template latest version"
  value       = aws_launch_template.app3.latest_version
}

output "app3_asg_id" {
  description = "App3 Auto Scaling Group ID"
  value       = aws_autoscaling_group.app3.id
}

output "app3_asg_name" {
  description = "App3 Auto Scaling Group name (use to find instances for SSM)"
  value       = aws_autoscaling_group.app3.name
}

output "app3_asg_arn" {
  description = "App3 Auto Scaling Group ARN"
  value       = aws_autoscaling_group.app3.arn
}

output "app3_asg_sns_topic_arn" {
  description = "SNS topic for App3 ASG notifications"
  value       = aws_sns_topic.app3_asg.arn
}

output "app3_asg_alb_resource_label" {
  description = "ALB + TG3 resource label used by request-count TTSP"
  value       = "${module.alb.arn_suffix}/${module.alb.target_groups["mytg3"].arn_suffix}"
}
