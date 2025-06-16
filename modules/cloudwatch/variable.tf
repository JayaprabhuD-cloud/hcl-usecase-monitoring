variable "cloudtrail_log_group_name" {
  description = "cloudtrail log group name"
  type = string
  default = "bayer-demo-cloudtrail-log-group"
}

variable "sns_topic_arn" {
  description = "sns topic arn variable"
  type = list(string)
}

variable "retention" {
  description = "logs retention days"
  type = number
}