# GitHub (v2) connection. Terraform can create it; AWS still requires a one-time
# console handshake (AWS Connector for GitHub) before status is AVAILABLE.

resource "aws_codestarconnections_connection" "github" {
  count         = var.codestar_connection_arn == null ? 1 : 0
  name          = var.codestar_connection_name
  provider_type = "GitHub"
  tags          = local.tags
}
