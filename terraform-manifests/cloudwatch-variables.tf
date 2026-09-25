# -----------------------------------------------------------------------------
# CloudWatch / Synthetics inputs
# Default canary URL follows the Route 53 record in route53.tf.
# -----------------------------------------------------------------------------

variable "canary_url" {
  description = "HTTPS URL the Synthetics canary probes. Leave null to use https://<dns_name>/"
  type        = string
  default     = null
}

variable "canary_schedule_expression" {
  description = "CloudWatch Synthetics schedule expression (demo default: every minute)"
  type        = string
  default     = "rate(1 minute)"
}

variable "canary_success_percent_threshold" {
  description = "Alarm when canary SuccessPercent average falls below this value"
  type        = number
  default     = 90
}
