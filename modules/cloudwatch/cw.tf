resource "aws_cloudwatch_log_group" "cloudtrail_log_group" {
  name              = var.cloudtrail_log_group_name
  retention_in_days = 90
}
