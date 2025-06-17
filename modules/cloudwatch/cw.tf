#resource "aws_cloudwatch_log_group" "cloudtrail_log_group" {
#  name              = var.cloudtrail_log_group_name
#  retention_in_days = var.retention
#}


resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = var.cloudtrail_log_group_name
#  retention_in_days = var.retention
}


resource "aws_cloudtrail" "main" {
  name                          = var.cloudtrail_name
  s3_bucket_name                = var.cloudtrail_bucket_name
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_role.arn

  depends_on = [aws_cloudwatch_log_group.cloudtrail]
}



## Creating multi region cloudtrail
#
#resource "aws_cloudtrail" "main" {
#  name                          = "jp-demo-multi-region-trail"
#  s3_bucket_name                = aws_s3_bucket.cloudtrail_bucket.id
#  include_global_service_events = true
#  is_multi_region_trail         = true
#  enable_log_file_validation    = true
#  cloud_watch_logs_group_arn    = aws_cloudwatch_log_group.cloudtrail_log_group.arn
#  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_role.arn
#
#  depends_on = [aws_cloudwatch_log_group.cloudtrail]
#}


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

resource "aws_iam_role_policy" "cloudtrail_policy" {
  name = "cloudtrail-logs"
  role = aws_iam_role.cloudtrail_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
      }
    ]
  })
}



#locals {
#  metrics = [
#    { name = "RootUsage", pattern = "{ $.userIdentity.type = \\\"Root\\\" }" },
#    { name = "IAMPolicyChanges", pattern = "{ ($.eventName = \\\"PutUserPolicy\\\") || ($.eventName = \\\"PutGroupPolicy\\\") || ($.eventName = \\\"PutRolePolicy\\\") || ($.eventName = \\\"DeleteUserPolicy\\\") || ($.eventName = \\\"DeleteGroupPolicy\\\") || ($.eventName = \\\"DeleteRolePolicy\\\") || ($.eventName = \\\"CreatePolicy\\\") || ($.eventName = \\\"DeletePolicy\\\") || ($.eventName = \\\"CreatePolicyVersion\\\") || ($.eventName = \\\"DeletePolicyVersion\\\") || ($.eventName = \\\"AttachRolePolicy\\\") || ($.eventName = \\\"DetachRolePolicy\\\") || ($.eventName = \\\"AttachUserPolicy\\\") || ($.eventName = \\\"DetachUserPolicy\\\") || ($.eventName = \\\"AttachGroupPolicy\\\") || ($.eventName = \\\"DetachGroupPolicy\\\") }" },
#    { name = "CloudTrailChanges", pattern = "{ ($.eventName = \\\"StopLogging\\\") || ($.eventName = \\\"DeleteTrail\\\") }" },
#    { name = "ConsoleLoginFailures", pattern = "{ ($.eventName = \\\"ConsoleLogin\\\") && ($.errorMessage = \\\"Failed authentication\\\") }" },
#    { name = "UnauthorizedAPICalls", pattern = "{ $.errorCode = \\\"*UnauthorizedOperation\\\" || $.errorCode = \\\"AccessDenied*\\\" }" },
#    { name = "SecurityGroupChanges", pattern = "{ ($.eventName = \\\"AuthorizeSecurityGroupIngress\\\") || ($.eventName = \\\"AuthorizeSecurityGroupEgress\\\") || ($.eventName = \\\"RevokeSecurityGroupIngress\\\") || ($.eventName = \\\"RevokeSecurityGroupEgress\\\") }" },
#    { name = "NetworkACLChanges", pattern = "{ ($.eventName = \\\"CreateNetworkAcl\\\") || ($.eventName = \\\"CreateNetworkAclEntry\\\") || ($.eventName = \\\"DeleteNetworkAcl\\\") || ($.eventName = \\\"DeleteNetworkAclEntry\\\") || ($.eventName = \\\"ReplaceNetworkAclEntry\\\") || ($.eventName = \\\"ReplaceNetworkAclAssociation\\\") }" },
#    { name = "NetworkGatewayChanges", pattern = "{ ($.eventName = \\\"CreateCustomerGateway\\\") || ($.eventName = \\\"DeleteCustomerGateway\\\") || ($.eventName = \\\"AttachInternetGateway\\\") || ($.eventName = \\\"CreateInternetGateway\\\") || ($.eventName = \\\"DeleteInternetGateway\\\") || ($.eventName = \\\"DetachInternetGateway\\\") }" },
#    { name = "RouteTableChanges", pattern = "{ ($.eventName = \\\"CreateRouteTable\\\") || ($.eventName = \\\"DeleteRouteTable\\\") || ($.eventName = \\\"ReplaceRouteTableAssociation\\\") || ($.eventName = \\\"CreateRoute\\\") || ($.eventName = \\\"ReplaceRoute\\\") || ($.eventName = \\\"DeleteRoute\\\") }" },
#    { name = "VpcChanges", pattern = "{ ($.eventName = \\\"CreateVpc\\\") || ($.eventName = \\\"DeleteVpc\\\") || ($.eventName = \\\"ModifyVpcAttribute\\\") || ($.eventName = \\\"AcceptVpcPeeringConnection\\\") || ($.eventName = \\\"CreateVpcPeeringConnection\\\") || ($.eventName = \\\"DeleteVpcPeeringConnection\\\") }" },
#    { name = "EC2InstanceChanges", pattern = "{ ($.eventName = \\\"RunInstances\\\") || ($.eventName = \\\"TerminateInstances\\\") || ($.eventName = \\\"StopInstances\\\") || ($.eventName = \\\"StartInstances\\\") }" },
#    { name = "KMSKeyChanges", pattern = "{ ($.eventSource = \\\"kms.amazonaws.com\\\") && (($.eventName = \\\"DisableKey\\\") || ($.eventName = \\\"ScheduleKeyDeletion\\\")) }" },
#    { name = "S3BucketPolicyChanges", pattern = "{ ($.eventName = \\\"PutBucketPolicy\\\") || ($.eventName = \\\"DeleteBucketPolicy\\\") }" },
#    { name = "AWSConfigChanges", pattern = "{ ($.eventSource = \\\"config.amazonaws.com\\\") && (($.eventName = \\\"StopConfigurationRecorder\\\") || ($.eventName = \\\"DeleteDeliveryChannel\\\")) }" }
#  ]
#}


## 1. Root user usage
#resource "aws_cloudwatch_log_metric_filter" "RootUsage" {
#  name           = "RootUsage"
#  log_group_name = var.cloudtrail_log_group_name
#  pattern        = "{ $.userIdentity.type = \"Root\" && $.userIdentity.invokedBy NOT EXISTS }"
#
#  metric_transformation {
#    name      = "RootUsage"
#    namespace = "SecurityHub"
#    value     = "1"
#  }
#}

## 2. Console login failures
#resource "aws_cloudwatch_log_metric_filter" "ConsoleLoginFailures" {
#  name           = "ConsoleLoginFailures"
#  log_group_name = var.cloudtrail_log_group_name
#  pattern        = "{ $.eventName = \"ConsoleLogin\" && $.responseElements.ConsoleLogin = \"Failure\" }"
#
#  metric_transformation {
#    name      = "ConsoleLoginFailures"
#    namespace = "SecurityHub"
#    value     = "1"
#  }
#}

## 3. IAM policy changes
#resource "aws_cloudwatch_log_metric_filter" "IAMPolicyChanges" {
#  name           = "IAMPolicyChanges"
#  log_group_name = var.cloudtrail_log_group_name
#  pattern        = "{ ($.eventName = \"PutGroupPolicy\") || ($.eventName = \"PutRolePolicy\") || ($.eventName = \"PutUserPolicy\") || ($.eventName = \"DeleteGroupPolicy\") || ($.eventName = \"DeleteRolePolicy\") || ($.eventName = \"DeleteUserPolicy\") || ($.eventName = \"CreatePolicy\") || ($.eventName = \"DeletePolicy\") || ($.eventName = \"CreatePolicyVersion\") || ($.eventName = \"DeletePolicyVersion\") || ($.eventName = \"AttachRolePolicy\") || ($.eventName = \"DetachRolePolicy\") || ($.eventName = \"AttachUserPolicy\") || ($.eventName = \"DetachUserPolicy\") || ($.eventName = \"AttachGroupPolicy\") || ($.eventName = \"DetachGroupPolicy\") }"
#
#  metric_transformation {
#    name      = "IAMPolicyChanges"
#    namespace = "SecurityHub"
#    value     = "1"
#  }
#}

# 4. CloudTrail configuration changes
resource "aws_cloudwatch_log_metric_filter" "CloudTrailChanges" {
  name           = "CloudTrailChanges"
  log_group_name = var.cloudtrail_log_group_name
  pattern        = "{ ($.eventName = \"CreateTrail\") || ($.eventName = \"UpdateTrail\") || ($.eventName = \"DeleteTrail\") || ($.eventName = \"StartLogging\") || ($.eventName = \"StopLogging\") }"

  metric_transformation {
    name      = "CloudTrailChanges"
    namespace = "SecurityHub"
    value     = "1"
  }
}

## 5. AWS Config changes
#resource "aws_cloudwatch_log_metric_filter" "AWSConfigChanges" {
#  name           = "AWSConfigChanges"
#  log_group_name = var.cloudtrail_log_group_name
#  pattern        = "{ ($.eventSource = \"config.amazonaws.com\") && ($.eventName = \"StopConfigurationRecorder\" || $.eventName = \"DeleteDeliveryChannel\") }"
#
#  metric_transformation {
#    name      = "AWSConfigChanges"
#    namespace = "SecurityHub"
#    value     = "1"
#  }
#}

# 6. Security group changes
resource "aws_cloudwatch_log_metric_filter" "SecurityGroupChanges" {
  name           = "SecurityGroupChanges"
  log_group_name = var.cloudtrail_log_group_name
  pattern        = "{ ($.eventName = \"AuthorizeSecurityGroupIngress\") || ($.eventName = \"AuthorizeSecurityGroupEgress\") || ($.eventName = \"RevokeSecurityGroupIngress\") || ($.eventName = \"RevokeSecurityGroupEgress\") || ($.eventName = \"CreateSecurityGroup\") || ($.eventName = \"DeleteSecurityGroup\") }"

  metric_transformation {
    name      = "SecurityGroupChanges"
    namespace = "SecurityHub"
    value     = "1"
  }
}

## 7. Network ACL changes
#resource "aws_cloudwatch_log_metric_filter" "NetworkACLChanges" {
#  name           = "NetworkACLChanges"
#  log_group_name = var.cloudtrail_log_group_name
#  pattern        = "{ ($.eventName = \"CreateNetworkAcl\") || ($.eventName = \"CreateNetworkAclEntry\") || ($.eventName = \"DeleteNetworkAcl\") || ($.eventName = \"DeleteNetworkAclEntry\") || ($.eventName = \"ReplaceNetworkAclEntry\") || ($.eventName = \"ReplaceNetworkAclAssociation\") }"
#
#  metric_transformation {
#    name      = "NetworkACLChanges"
#    namespace = "SecurityHub"
#    value     = "1"
#  }
#}

## 8. Route table changes
#resource "aws_cloudwatch_log_metric_filter" "RouteTableChanges" {
#  name           = "RouteTableChanges"
#  log_group_name = var.cloudtrail_log_group_name
#  pattern        = "{ ($.eventName = \"CreateRouteTable\") || ($.eventName = \"DeleteRouteTable\") || ($.eventName = \"ReplaceRouteTableAssociation\") || ($.eventName = \"CreateRoute\") || ($.eventName = \"ReplaceRoute\") || ($.eventName = \"DeleteRoute\") }"
#
#  metric_transformation {
#    name      = "RouteTableChanges"
#    namespace = "SecurityHub"
#    value     = "1"
#  }
#}

## 9. VPC changes
#resource "aws_cloudwatch_log_metric_filter" "VpcChanges" {
#  name           = "VpcChanges"
#  log_group_name = var.cloudtrail_log_group_name
#  pattern        = "{ ($.eventName = \"CreateVpc\") || ($.eventName = \"DeleteVpc\") || ($.eventName = \"ModifyVpcAttribute\") || ($.eventName = \"AcceptVpcPeeringConnection\") || ($.eventName = \"CreateVpcPeeringConnection\") || ($.eventName = \"DeleteVpcPeeringConnection\") }"
#
#  metric_transformation {
#    name      = "VpcChanges"
#    namespace = "SecurityHub"
#    value     = "1"
#  }
#}

## 10. KMS key changes
#resource "aws_cloudwatch_log_metric_filter" "KMSKeyChanges" {
#  name           = "KMSKeyChanges"
#  log_group_name = var.cloudtrail_log_group_name
#  pattern        = "{ ($.eventSource = \"kms.amazonaws.com\") && ($.eventName = \"DisableKey\" || $.eventName = \"ScheduleKeyDeletion\") }"
#
#  metric_transformation {
#    name      = "KMSKeyChanges"
#    namespace = "SecurityHub"
#    value     = "1"
#  }
#}

## 11. EC2 instance changes
#resource "aws_cloudwatch_log_metric_filter" "EC2InstanceChanges" {
#  name           = "EC2InstanceChanges"
#  log_group_name = var.cloudtrail_log_group_name
#  pattern        = "{ ($.eventName = \"RunInstances\") || ($.eventName = \"TerminateInstances\") || ($.eventName = \"StopInstances\") || ($.eventName = \"StartInstances\") }"
#
#  metric_transformation {
#    name      = "EC2InstanceChanges"
#    namespace = "SecurityHub"
#    value     = "1"
#  }
#}

# 12. Unauthorized API calls
resource "aws_cloudwatch_log_metric_filter" "UnauthorizedAPICalls" {
  name           = "UnauthorizedAPICalls"
  log_group_name = var.cloudtrail_log_group_name
  pattern        = "{ $.errorCode = \"*UnauthorizedOperation\" || $.errorCode = \"AccessDenied*\" }"

  metric_transformation {
    name      = "UnauthorizedAPICalls"
    namespace = "SecurityHub"
    value     = "1"
  }
}

# 13. Management console sign-in without MFA
resource "aws_cloudwatch_log_metric_filter" "ConsoleSigninWithoutMFA" {
  name           = "ConsoleSigninWithoutMFA"
  log_group_name = var.cloudtrail_log_group_name
  pattern        = "{ $.eventName = \"ConsoleLogin\" && $.additionalEventData.MFAUsed = \"No\" }"

  metric_transformation {
    name      = "ConsoleSigninWithoutMFA"
    namespace = "SecurityHub"
    value     = "1"
  }
}

## 14. S3 bucket policy changes
#resource "aws_cloudwatch_log_metric_filter" "S3BucketPolicyChanges" {
#  name           = "S3BucketPolicyChanges"
#  log_group_name = var.cloudtrail_log_group_name
#  pattern        = "{ ($.eventName = \"PutBucketPolicy\") || ($.eventName = \"DeleteBucketPolicy\") }"
#
#  metric_transformation {
#    name      = "S3BucketPolicyChanges"
#    namespace = "SecurityHub"
#    value     = "1"
#  }
#}

# Creating cloudwatch alarms for above metrics

#resource "aws_cloudwatch_metric_alarm" "RootUsageAlarm" {
#  alarm_name          = "RootUsageAlarm"
#  comparison_operator = "GreaterThanOrEqualToThreshold"
#  evaluation_periods  = 1
#  metric_name         = "RootUsage"
#  namespace           = "SecurityHub"
#  period              = 300
#  statistic           = "Sum"
#  threshold           = 1
#  alarm_description   = "Alarm for root user activity"
#  alarm_actions       = var.sns_topic_arn
#}

#resource "aws_cloudwatch_metric_alarm" "ConsoleLoginFailuresAlarm" {
#  alarm_name          = "ConsoleLoginFailuresAlarm"
#  comparison_operator = "GreaterThanOrEqualToThreshold"
#  evaluation_periods  = 1
#  metric_name         = "ConsoleLoginFailures"
#  namespace           = "SecurityHub"
#  period              = 300
#  statistic           = "Sum"
#  threshold           = 1
#  alarm_description   = "Alarm for console login failures"
#  alarm_actions       = var.sns_topic_arn
#}

#resource "aws_cloudwatch_metric_alarm" "IAMPolicyChangesAlarm" {
#  alarm_name          = "IAMPolicyChangesAlarm"
#  comparison_operator = "GreaterThanOrEqualToThreshold"
#  evaluation_periods  = 1
#  metric_name         = "IAMPolicyChanges"
#  namespace           = "SecurityHub"
#  period              = 300
#  statistic           = "Sum"
#  threshold           = 1
#  alarm_description   = "Alarm for IAM policy changes"
#  alarm_actions       = var.sns_topic_arn
#}

resource "aws_cloudwatch_metric_alarm" "CloudTrailChangesAlarm" {
  alarm_name          = "CloudTrailChangesAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CloudTrailChanges"
  namespace           = "SecurityHub"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm for CloudTrail configuration changes"
  alarm_actions       = var.sns_topic_arn
}

#resource "aws_cloudwatch_metric_alarm" "AWSConfigChangesAlarm" {
#  alarm_name          = "AWSConfigChangesAlarm"
#  comparison_operator = "GreaterThanOrEqualToThreshold"
#  evaluation_periods  = 1
#  metric_name         = "AWSConfigChanges"
#  namespace           = "SecurityHub"
#  period              = 300
#  statistic           = "Sum"
#  threshold           = 1
#  alarm_description   = "Alarm for AWS Config changes"
#  alarm_actions       = var.sns_topic_arn
#}

resource "aws_cloudwatch_metric_alarm" "SecurityGroupChangesAlarm" {
  alarm_name          = "SecurityGroupChangesAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "SecurityGroupChanges"
  namespace           = "SecurityHub"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm for security group changes"
  alarm_actions       = var.sns_topic_arn
}

#resource "aws_cloudwatch_metric_alarm" "NetworkACLChangesAlarm" {
#  alarm_name          = "NetworkACLChangesAlarm"
#  comparison_operator = "GreaterThanOrEqualToThreshold"
#  evaluation_periods  = 1
#  metric_name         = "NetworkACLChanges"
#  namespace           = "SecurityHub"
#  period              = 300
#  statistic           = "Sum"
#  threshold           = 1
#  alarm_description   = "Alarm for network ACL changes"
#  alarm_actions       = var.sns_topic_arn
#}

resource "aws_cloudwatch_metric_alarm" "RouteTableChangesAlarm" {
  alarm_name          = "RouteTableChangesAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "RouteTableChanges"
  namespace           = "SecurityHub"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm for route table changes"
  alarm_actions       = var.sns_topic_arn
}

resource "aws_cloudwatch_metric_alarm" "VpcChangesAlarm" {
  alarm_name          = "VpcChangesAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "VpcChanges"
  namespace           = "SecurityHub"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm for VPC changes"
  alarm_actions       = var.sns_topic_arn
}

resource "aws_cloudwatch_metric_alarm" "KMSKeyChangesAlarm" {
  alarm_name          = "KMSKeyChangesAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "KMSKeyChanges"
  namespace           = "SecurityHub"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm for KMS key changes"
  alarm_actions       = var.sns_topic_arn
}

resource "aws_cloudwatch_metric_alarm" "EC2InstanceChangesAlarm" {
  alarm_name          = "EC2InstanceChangesAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "EC2InstanceChanges"
  namespace           = "SecurityHub"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm for EC2 instance changes"
  alarm_actions       = var.sns_topic_arn
}

resource "aws_cloudwatch_metric_alarm" "UnauthorizedAPICallsAlarm" {
  alarm_name          = "UnauthorizedAPICallsAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "UnauthorizedAPICalls"
  namespace           = "SecurityHub"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm for unauthorized API calls"
  alarm_actions       = var.sns_topic_arn
}

resource "aws_cloudwatch_metric_alarm" "ConsoleSigninWithoutMFAAlarm" {
  alarm_name          = "ConsoleSigninWithoutMFAAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ConsoleSigninWithoutMFA"
  namespace           = "SecurityHub"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm for console sign-in without MFA"
  alarm_actions       = var.sns_topic_arn
}

resource "aws_cloudwatch_metric_alarm" "S3BucketPolicyChangesAlarm" {
  alarm_name          = "S3BucketPolicyChangesAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "S3BucketPolicyChanges"
  namespace           = "SecurityHub"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm for S3 bucket policy changes"
  alarm_actions       = var.sns_topic_arn
}




## Creating cloudwatch log group metric filters
#
#resource "aws_cloudwatch_log_metric_filter" "filters" {
#  for_each = { for metric in local.metrics : metric.name => metric }
#
#  name           = each.value.name
#  log_group_name = aws_cloudwatch_log_group.cloudtrail_log_group.name
#  pattern        = each.value.pattern
#
#  metric_transformation {
#    name      = each.value.name
#    namespace = "SecurityMetrics"
#    value     = "1"
#  }
#}
#
## Creating cloudwatch alarms for custom metrics
#
#resource "aws_cloudwatch_metric_alarm" "alarms" {
#  for_each = aws_cloudwatch_log_metric_filter.filters
#
#  alarm_name          = "${each.key}_alarm"
#  comparison_operator = "GreaterThanOrEqualToThreshold"
#  evaluation_periods  = 1
#  metric_name         = each.key
#  namespace           = "SecurityMetrics"
#  period              = 300
#  statistic           = "Sum"
#  threshold           = 1
#  alarm_description   = "Alarm for ${each.key} metric"
#  alarm_actions       = [var.sns_topic_arn]
#}



# modules/cloudwatch/outputs.tf
output "log_group_arn" {
  value = aws_cloudwatch_log_group.cloudtrail.arn
}
