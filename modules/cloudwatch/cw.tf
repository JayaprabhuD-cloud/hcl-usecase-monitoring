resource "aws_cloudwatch_log_group" "cloudtrail_log_group" {
  name              = var.cloudtrail_log_group_name
  retention_in_days = var.retention
}

# Creating IAM role for Cloudtrail

resource "aws_iam_role" "cloudtrail_role" {
  name = "cloudtrail_cloudwatch_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "cloudtrail.amazonaws.com"
      },
      Effect = "Allow",
      Sid    = ""
    }]
  })
}

# Creating IAM Policy for cloudtrail role

resource "aws_iam_role_policy" "cloudtrail_policy" {
  name = "cloudtrail_cloudwatch_policy"
  role = aws_iam_role.cloudtrail_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "logs:PutLogEvents",
        "logs:CreateLogStream"
      ],
      Resource = "${aws_cloudwatch_log_group.cloudtrail_log_group.arn}:*"
    }]
  })
}

locals {
  metrics = [
    { name = "RootUsage", pattern = "{ $.userIdentity.type = \\\"Root\\\" }" },
    { name = "IAMPolicyChanges", pattern = "{ ($.eventName = \\\"PutUserPolicy\\\") || ($.eventName = \\\"PutGroupPolicy\\\") || ($.eventName = \\\"PutRolePolicy\\\") || ($.eventName = \\\"DeleteUserPolicy\\\") || ($.eventName = \\\"DeleteGroupPolicy\\\") || ($.eventName = \\\"DeleteRolePolicy\\\") || ($.eventName = \\\"CreatePolicy\\\") || ($.eventName = \\\"DeletePolicy\\\") || ($.eventName = \\\"CreatePolicyVersion\\\") || ($.eventName = \\\"DeletePolicyVersion\\\") || ($.eventName = \\\"AttachRolePolicy\\\") || ($.eventName = \\\"DetachRolePolicy\\\") || ($.eventName = \\\"AttachUserPolicy\\\") || ($.eventName = \\\"DetachUserPolicy\\\") || ($.eventName = \\\"AttachGroupPolicy\\\") || ($.eventName = \\\"DetachGroupPolicy\\\") }" },
    { name = "CloudTrailChanges", pattern = "{ ($.eventName = \\\"StopLogging\\\") || ($.eventName = \\\"DeleteTrail\\\") }" },
    { name = "ConsoleLoginFailures", pattern = "{ ($.eventName = \\\"ConsoleLogin\\\") && ($.errorMessage = \\\"Failed authentication\\\") }" },
    { name = "UnauthorizedAPICalls", pattern = "{ $.errorCode = \\\"*UnauthorizedOperation\\\" || $.errorCode = \\\"AccessDenied*\\\" }" },
    { name = "SecurityGroupChanges", pattern = "{ ($.eventName = \\\"AuthorizeSecurityGroupIngress\\\") || ($.eventName = \\\"AuthorizeSecurityGroupEgress\\\") || ($.eventName = \\\"RevokeSecurityGroupIngress\\\") || ($.eventName = \\\"RevokeSecurityGroupEgress\\\") }" },
    { name = "NetworkACLChanges", pattern = "{ ($.eventName = \\\"CreateNetworkAcl\\\") || ($.eventName = \\\"CreateNetworkAclEntry\\\") || ($.eventName = \\\"DeleteNetworkAcl\\\") || ($.eventName = \\\"DeleteNetworkAclEntry\\\") || ($.eventName = \\\"ReplaceNetworkAclEntry\\\") || ($.eventName = \\\"ReplaceNetworkAclAssociation\\\") }" },
    { name = "NetworkGatewayChanges", pattern = "{ ($.eventName = \\\"CreateCustomerGateway\\\") || ($.eventName = \\\"DeleteCustomerGateway\\\") || ($.eventName = \\\"AttachInternetGateway\\\") || ($.eventName = \\\"CreateInternetGateway\\\") || ($.eventName = \\\"DeleteInternetGateway\\\") || ($.eventName = \\\"DetachInternetGateway\\\") }" },
    { name = "RouteTableChanges", pattern = "{ ($.eventName = \\\"CreateRouteTable\\\") || ($.eventName = \\\"DeleteRouteTable\\\") || ($.eventName = \\\"ReplaceRouteTableAssociation\\\") || ($.eventName = \\\"CreateRoute\\\") || ($.eventName = \\\"ReplaceRoute\\\") || ($.eventName = \\\"DeleteRoute\\\") }" },
    { name = "VpcChanges", pattern = "{ ($.eventName = \\\"CreateVpc\\\") || ($.eventName = \\\"DeleteVpc\\\") || ($.eventName = \\\"ModifyVpcAttribute\\\") || ($.eventName = \\\"AcceptVpcPeeringConnection\\\") || ($.eventName = \\\"CreateVpcPeeringConnection\\\") || ($.eventName = \\\"DeleteVpcPeeringConnection\\\") }" },
    { name = "EC2InstanceChanges", pattern = "{ ($.eventName = \\\"RunInstances\\\") || ($.eventName = \\\"TerminateInstances\\\") || ($.eventName = \\\"StopInstances\\\") || ($.eventName = \\\"StartInstances\\\") }" },
    { name = "KMSKeyChanges", pattern = "{ ($.eventSource = \\\"kms.amazonaws.com\\\") && (($.eventName = \\\"DisableKey\\\") || ($.eventName = \\\"ScheduleKeyDeletion\\\")) }" },
    { name = "S3BucketPolicyChanges", pattern = "{ ($.eventName = \\\"PutBucketPolicy\\\") || ($.eventName = \\\"DeleteBucketPolicy\\\") }" },
    { name = "AWSConfigChanges", pattern = "{ ($.eventSource = \\\"config.amazonaws.com\\\") && (($.eventName = \\\"StopConfigurationRecorder\\\") || ($.eventName = \\\"DeleteDeliveryChannel\\\")) }" }
  ]
}


# Creating cloudwatch log group metric filters

resource "aws_cloudwatch_log_metric_filter" "filters" {
  for_each = { for metric in local.metrics : metric.name => metric }

  name           = each.value.name
  log_group_name = aws_cloudwatch_log_group.cloudtrail_log_group.name
  pattern        = each.value.pattern

  metric_transformation {
    name      = each.value.name
    namespace = "SecurityMetrics"
    value     = "1"
  }
}

# Creating cloudwatch alarms for custom metrics

resource "aws_cloudwatch_metric_alarm" "alarms" {
  for_each = aws_cloudwatch_log_metric_filter.filters

  alarm_name          = "${each.key}_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = each.key
  namespace           = "SecurityMetrics"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm for ${each.key} metric"
  alarm_actions       = var.sns_topic_arn
}
