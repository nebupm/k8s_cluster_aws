output "sg_alb_id" {
  description = "Security group ID for the internet-facing ALB."
  value       = aws_security_group.alb.id
}

output "sg_cp_id" {
  description = "Security group ID for control plane nodes."
  value       = aws_security_group.cp.id
}

output "sg_worker_id" {
  description = "Security group ID for worker nodes."
  value       = aws_security_group.worker.id
}
