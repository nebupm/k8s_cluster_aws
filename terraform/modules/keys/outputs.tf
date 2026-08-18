output "key_name" {
  description = "EC2 Key Pair name — pass to the compute module."
  value       = aws_key_pair.cluster.key_name
}

output "ssm_parameter_name" {
  description = "SSM Parameter Store path for the SSH private key."
  value       = aws_ssm_parameter.ssh_private_key.name
}
