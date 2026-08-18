output "cp_instance_ids" {
  description = "Map of control plane node key to instance ID — used for NLB target group registration."
  value       = { for k, v in aws_instance.control_plane : k => v.id }
}

output "cp_private_ips" {
  description = "Map of control plane node key to private IP — used for Ansible inventory."
  value       = { for k, v in aws_instance.control_plane : k => v.private_ip }
}

output "worker_instance_ids" {
  description = "Map of worker node key to instance ID — used for ALB target group registration."
  value       = { for k, v in aws_instance.worker : k => v.id }
}

output "worker_private_ips" {
  description = "Map of worker node key to private IP — used for Ansible inventory."
  value       = { for k, v in aws_instance.worker : k => v.private_ip }
}
