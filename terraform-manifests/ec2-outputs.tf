# AWS EC2 Instance Terraform Outputs
# Bastion removed (Phase 5) — admin access is SSM Session Manager on App3 ASG instances.

# App1 - Private EC2 Instances
output "app1_ec2_private_instance_ids" {
  description = "List of IDs of instances"
  value       = [for ec2private in module.ec2_private_app1 : ec2private.id]
}

output "app1_ec2_private_ip" {
  description = "List of private IP addresses assigned to the instances"
  value       = [for ec2private in module.ec2_private_app1 : ec2private.private_ip]
}

# App2 - Private EC2 Instances
output "app2_ec2_private_instance_ids" {
  description = "List of IDs of instances"
  value       = [for ec2private in module.ec2_private_app2 : ec2private.id]
}

output "app2_ec2_private_ip" {
  description = "List of private IP addresses assigned to the instances"
  value       = [for ec2private in module.ec2_private_app2 : ec2private.private_ip]
}
