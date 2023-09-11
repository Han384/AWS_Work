# S3 bucket 名にランダム文字列を使用するための記述
resource "random_string" "s3_unique_key" {
  length  = 6
  upper   = false
  lower   = true
  numeric = true
  special = false
}

# ---------------------------------------------
# S3 bucket
# ---------------------------------------------
resource "aws_s3_bucket" "S3Bucket" {
  bucket = "${var.project}-${var.environment}-bucket-${random_string.s3_unique_key.result}"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "S3Bucket" {
  bucket = aws_s3_bucket.S3Bucket.id

  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
  