variable "cloudtrail_bucket_name" {
  description = "name of the s3 bucket"
  type = string
  default = "bayer-demo-cloudtrail-logs"
}

variable "cloudtrail_log_group_name" {
  description = "cloudtrail log group name"
  type = string
  default = "bayer-demo-cloudtrail-log-group"
}

#variable "retention" {
#  description = "logs retention days"
#  type = number
#}

#variable "sns_topic_arn" {
#  description = "sns topic arn variable"
#  type = string
#}

variable "sns_topic_name" {
  description = "SNS topic name"
  type = string
  default = "cloudwatch-custom-metric-topic"
}

variable "cloudtrail_name" {
  description = "Name of the cloudtrail"
  type = string
  default = "jp-demo-multi-region-trail"
}