# AWS EC2 Instance Terraform Variables

variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t3.micro"
}
