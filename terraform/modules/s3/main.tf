resource "aws_s3_bucket" "react_site" {
  bucket = var.bucket_name
  force_destroy = true
}