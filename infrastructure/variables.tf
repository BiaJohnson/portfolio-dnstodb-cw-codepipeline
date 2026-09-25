# Input Variables
# AWS Region
variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type        = string
  default     = "us-east-1"
}
# Environment Variable
variable "environment" {
  description = "Environment Variable used as a prefix"
  type        = string
  default     = "dev"
}
# Business Division
variable "business_divsion" {
  description = "Business Division in the large organization this Infrastructure belongs"
  type        = string
  default     = "sap"
}

# Route 53 public hosted zone (replace in terraform.tfvars with YOUR domain)
variable "route53_zone_name" {
  description = "Your public Route 53 hosted zone (e.g. example.com). Not created by this stack."
  type        = string
}
