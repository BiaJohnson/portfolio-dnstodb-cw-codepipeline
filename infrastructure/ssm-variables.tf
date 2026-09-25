# -----------------------------------------------------------------------------
# Phase B — App3 DB credentials (SSM Parameter Store inputs)
# Password comes from gitignored secrets.tfvars (app3_db_password).
# Pipeline: CodeBuild injects SSM /CodeBuild/APP3_DB_PASSWORD and writes that file.
# Terraform then stores it as SecureString /<env>/app3/db/password for App3 EC2.
# -----------------------------------------------------------------------------

variable "app3_db_username" {
  description = "Least-privilege MySQL username for App3 UMS (not the RDS master)"
  type        = string
  default     = "app3"
}

variable "app3_db_password" {
  description = "Password for App3 MySQL user; stored as SSM SecureString"
  type        = string
  sensitive   = true
}

variable "app3_db_name" {
  description = "MySQL database name used by App3 UMS"
  type        = string
  default     = "webappdb"
}

variable "app3_db_port" {
  description = "MySQL port used by App3 UMS"
  type        = string
  default     = "3306"
}
