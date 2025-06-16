output "log_group_arn" {
  description = "The ARN of the CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.cloudtrail_log_group.arn
}


output "cloudtrail_iam_role_arn" {
  description = "The ARN of the IAM role"
  value       = aws_iam_role.cloudtrail_role.arn
}