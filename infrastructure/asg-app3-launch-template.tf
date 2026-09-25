# -----------------------------------------------------------------------------
# Phase 7 — Launch Template for App3 (UMS)
# IAM + Parameter Store userdata (same bootstrap as former fixed App3 EC2).
# No secrets in the template; omit key_name (Session Manager only).
# -----------------------------------------------------------------------------

resource "aws_launch_template" "app3" {
  name_prefix   = "${local.name}-app3-lt-"
  description   = "App3 UMS — IAM + SSM Parameter Store bootstrap"
  image_id      = data.aws_ami.amzlinux2.id
  instance_type = var.instance_type

  vpc_security_group_ids = [module.app3_sg.security_group_id]

  iam_instance_profile {
    name = aws_iam_instance_profile.app3.name
  }

  user_data = base64encode(templatefile("${path.module}/app3-ums-install.tmpl", {
    rds_db_endpoint = module.rdsdb.db_instance_address
    aws_region      = var.aws_region
    ssm_db_path     = "/${var.environment}/app3/db"
  }))

  update_default_version = true
  ebs_optimized          = true

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(local.common_tags, {
      Name = "${local.name}-app3"
    })
  }

  tags = local.common_tags
}
