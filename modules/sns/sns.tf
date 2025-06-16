resource "aws_sns_topic" "cloudtrail_alarms" {
  name = var.sns_topic_name
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.cloudtrail_alarms.arn
  protocol  = "email"
  endpoint  = "jayaprabhu.dheen@hcltech.com"
}