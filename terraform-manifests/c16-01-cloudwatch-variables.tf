# -----------------------------------------------------------------------------
# CloudWatch / Synthetics inputs
# Default canary URL follows the portfolio Route 53 record (c12).
# -----------------------------------------------------------------------------

variable "canary_url" {
  description = "HTTPS URL the Synthetics canary probes. Leave null to use https://<c12 apps_dns FQDN>/"
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
