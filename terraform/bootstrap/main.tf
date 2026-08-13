terraform {
  required_version = ">= 1.13.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  # State stored locally per workspace: terraform.tfstate.d/<env>/terraform.tfstate
  # Commit this directory to preserve the bucket names.
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

# One S3 bucket per environment tier (dev / staging / prod).
# Run once per tier:
#   terraform workspace new dev
#   terraform apply -var="environment=dev" -var="aws_region=eu-west-2"
resource "aws_s3_bucket" "tfstate" {
  bucket_prefix = "ntegra-k8s-${var.environment}-tfstate-"
  force_destroy = var.force_destroy

  tags = {
    Name        = "ntegra-k8s-${var.environment}-tfstate"
    Environment = var.environment
    ManagedBy   = "terraform"
    Who         = var.tag_who
    What        = var.tag_what
    Why         = var.tag_why
  }
}

resource "aws_s3_bucket_versioning" "tfstate" {
  count  = var.enable_versioning ? 1 : 0
  bucket = aws_s3_bucket.tfstate.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  count  = var.enable_encryption ? 1 : 0
  bucket = aws_s3_bucket.tfstate.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
