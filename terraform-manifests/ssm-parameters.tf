# -----------------------------------------------------------------------------
# Phase B — SSM Parameter Store for App3 DB credentials
# Host stays in userdata via module.rdsdb.db_instance_address (not duplicated here).
# Path: /<environment>/app3/db/*  e.g. /stag/app3/db/password
# -----------------------------------------------------------------------------

resource "aws_ssm_parameter" "app3_db_username" {
  name        = "/${var.environment}/app3/db/username"
  description = "App3 MySQL username (least privilege)"
  type        = "String"
  value       = var.app3_db_username
  tags        = local.common_tags
}

resource "aws_ssm_parameter" "app3_db_password" {
  name        = "/${var.environment}/app3/db/password"
  description = "App3 MySQL password (SecureString)"
  type        = "SecureString"
  value       = var.app3_db_password
  tags        = local.common_tags
}

resource "aws_ssm_parameter" "app3_db_name" {
  name        = "/${var.environment}/app3/db/name"
  description = "App3 MySQL database name"
  type        = "String"
  value       = var.app3_db_name
  tags        = local.common_tags
}

resource "aws_ssm_parameter" "app3_db_port" {
  name        = "/${var.environment}/app3/db/port"
  description = "App3 MySQL port"
  type        = "String"
  value       = var.app3_db_port
  tags        = local.common_tags
}
