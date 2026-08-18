locals {
  connection_arn = var.codestar_connection_arn != null ? var.codestar_connection_arn : aws_codestarconnections_connection.github[0].arn

  artifact_bucket_name = var.pipeline_artifact_bucket_name != "" ? var.pipeline_artifact_bucket_name : "${data.aws_caller_identity.current.account_id}-dnstodb-cw-cp-artifacts"

  ssm_parameter_arns = [
    "arn:${data.aws_partition.current.partition}:ssm:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:parameter/CodeBuild/DB_PASSWORD",
    "arn:${data.aws_partition.current.partition}:ssm:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:parameter/CodeBuild/APP3_DB_PASSWORD",
  ]

  tags = {
    Project   = "dnstodb-cw"
    Component = "pipeline"
    Terraform = "true"
  }
}
