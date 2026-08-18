resource "aws_s3_bucket" "terraform_state" {
  #tf-gitops-dev-terraform-state
  bucket_prefix = "${var.prefix}-${var.environment}-${var.bucket_name}"
  force_destroy = var.force_destroy
  tags = {
    Who         = var.tag_who
    What        = var.tag_what
    Why         = var.tag_why
    Environment = var.environment
    Name        = "${var.prefix}-${var.environment}-${var.bucket_name}"
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  count  = var.enable_versioning ? 1 : 0
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  count  = var.enable_encryption ? 1 : 0
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_account_public_access_block" "terraform_state_public_access" {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
