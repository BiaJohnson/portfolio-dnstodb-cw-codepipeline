# Get DNS information from AWS Route53
# Replace example.com with your Route 53 public hosted zone (see README).
data "aws_route53_zone" "mydomain" {
  name = "biademos.com"
}

# Output MyDomain Zone ID
output "mydomain_zoneid" {
  description = "The Hosted Zone id of the desired Hosted Zone"
  value       = data.aws_route53_zone.mydomain.zone_id
}

# Output MyDomain name
output "mydomain_name" {
  description = " The Hosted Zone name of the desired Hosted Zone."
  value       = data.aws_route53_zone.mydomain.name
}
