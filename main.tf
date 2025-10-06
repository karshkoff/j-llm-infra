provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

resource "aws_s3_bucket" "tf-state-bucket" {
  bucket = "${var.project}-tf-state-bucket"

  tags = {
    project = var.project
    repo    = var.repo
  }
}

resource "aws_s3_bucket_public_access_block" "tf-state-public-access-block" {
  bucket = aws_s3_bucket.tf-state-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
