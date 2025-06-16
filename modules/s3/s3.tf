resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket = var.cloudtrail_bucket_name

  tags = {
    Name = "var.cloudtrail_bucket_name"
  }
}