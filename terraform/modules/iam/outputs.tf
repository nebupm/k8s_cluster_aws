output "instance_profile_name" {
  description = "IAM instance profile name — pass to the compute module."
  value       = aws_iam_instance_profile.node.name
}

output "instance_profile_arn" {
  description = "IAM instance profile ARN."
  value       = aws_iam_instance_profile.node.arn
}
