resource "aws_sns_topic" "cloudtrail_alarms" {
  name = var.sns_topic_name
}