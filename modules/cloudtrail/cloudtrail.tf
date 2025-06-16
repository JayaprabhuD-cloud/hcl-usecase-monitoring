# Creating multi region cloudtrail

resource "aws_cloudtrail" "main" {
  name                          = var.cloudtrail_name
  s3_bucket_name                = var.cloudtrail_bucket_name
  cloud_watch_logs_group_arn    = var.log_group_arn
  cloud_watch_logs_role_arn     = var.cloudtrail_iam_role_arn
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
}
