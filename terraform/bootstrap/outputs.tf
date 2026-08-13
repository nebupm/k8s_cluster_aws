output "state_bucket_name" {
  description = "S3 bucket name for this environment tier — copy into backends/<team>-<env>.hcl."
  value       = aws_s3_bucket.tfstate.bucket
}
