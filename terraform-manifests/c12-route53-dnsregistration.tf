# DNS Name Input Variable
variable "dns_name" {
  description = "FQDN for this environment (e.g. dns-to-db-dev.biademos.com). Hosted zone stays biademos.com."
  type        = string
}

# DNS Registration
resource "aws_route53_record" "apps_dns" {
  zone_id = data.aws_route53_zone.mydomain.zone_id
  name    = var.dns_name
  type    = "A"
  alias {
    name                   = module.alb.dns_name
    zone_id                = module.alb.zone_id
    evaluate_target_health = true
  }
}
