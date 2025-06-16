variable "log_group_arn" {
  description = "variable for cloudwatch log group arn"
  type = string
}

variable "cloudtrail_iam_role_arn" {
  description = "variable for cloudtrail IAM role arn"
  type = string
}


variable "cloudtrail_name" {
  description = "Name of the cloudtrail"
  type = string
  default = "jp-demo-multi-region-trail"
}

variable "cloudtrail_bucket_name" {
  description = "Name of the s3 bucket"
  type = string
}