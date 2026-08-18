# -----------------------------------------------------------------------------
# Phase 7–9 — App3 Launch Template + Auto Scaling Group variables
# Lab-safe defaults: min/desired=2, max=4
# -----------------------------------------------------------------------------

variable "app3_asg_desired_capacity" {
  description = "Desired number of App3 ASG instances"
  type        = number
  default     = 2
}

variable "app3_asg_min_size" {
  description = "Minimum App3 ASG size"
  type        = number
  default     = 2
}

variable "app3_asg_max_size" {
  description = "Maximum App3 ASG size (keep low for personal AWS accounts)"
  type        = number
  default     = 4
}

variable "app3_asg_health_check_grace_period" {
  description = "Seconds to wait for WAR/Tomcat boot before ELB health checks count"
  type        = number
  default     = 300
}

variable "asg_notification_email" {
  description = "Email for ASG launch/terminate SNS notifications (confirm subscription in inbox)"
  type        = string
  default     = "you@example.com"
}

variable "app3_asg_cpu_target" {
  description = "Target average CPU % for ASG target-tracking policy"
  type        = number
  default     = 50.0
}

variable "app3_asg_request_count_target" {
  description = "Target ALB request count per target for App3 TG"
  type        = number
  default     = 10.0
}
