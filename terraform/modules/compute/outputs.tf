output "cp_instance_ids" {
  value = { for k, v in aws_instance.control_plane : k => v.id }
}

output "cp_private_ips" {
  value = { for k, v in aws_instance.control_plane : k => v.private_ip }
}

output "worker_instance_ids" {
  value = { for k, v in aws_instance.worker : k => v.id }
}

output "worker_private_ips" {
  value = { for k, v in aws_instance.worker : k => v.private_ip }
}
