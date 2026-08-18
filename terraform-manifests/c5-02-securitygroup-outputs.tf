# AWS EC2 Security Group Terraform Outputs
# Bastion SG removed (Phase 5).

# App1 / App2 private SG
output "private_sg_group_id" {
  description = "The ID of the App1/App2 security group"
  value       = module.private_sg.security_group_id
}

output "private_sg_group_vpc_id" {
  description = "The VPC ID"
  value       = module.private_sg.security_group_vpc_id
}

output "private_sg_group_name" {
  description = "The name of the App1/App2 security group"
  value       = module.private_sg.security_group_name
}

# App3 ASG SG (RDS allows MySQL from this SG only)
output "app3_sg_group_id" {
  description = "The ID of the App3 security group"
  value       = module.app3_sg.security_group_id
}

output "app3_sg_group_name" {
  description = "The name of the App3 security group"
  value       = module.app3_sg.security_group_name
}
