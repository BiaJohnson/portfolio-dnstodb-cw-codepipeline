# Auto Scaling service-linked role is account-wide and usually already exists
# (creating it again fails with "has been taken in this account").
# Reference it so the ASG still waits for the role to be present.
data "aws_iam_role" "autoscaling" {
  name = "AWSServiceRoleForAutoScaling"
}
