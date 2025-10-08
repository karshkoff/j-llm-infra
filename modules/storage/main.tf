resource "aws_s3_bucket" "tf-backend" {
  bucket        = var.backend_bucket
  force_destroy = true

  tags = var.tags
}


# All buckets are private by default
resource "aws_s3_bucket_public_access_block" "tf-backend-private" {
  bucket = aws_s3_bucket.tf-backend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}