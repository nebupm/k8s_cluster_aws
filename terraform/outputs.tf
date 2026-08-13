output "cluster_name" {
  description = "Cluster name — used by generate_inventory.sh to name the inventory file."
  value       = var.cluster_name
}

output "api_nlb_dns_name" {
  description = "Internal NLB DNS — set as kubeadm --control-plane-endpoint."
  value       = module.load_balancer.api_nlb_dns_name
}

output "alb_dns_name" {
  description = "Public ALB DNS for application traffic."
  value       = module.load_balancer.alb_dns_name
}

output "cp_private_ips" {
  description = "Map of control plane node key to private IP."
  value       = module.compute.cp_private_ips
}

output "worker_private_ips" {
  description = "Map of worker node key to private IP."
  value       = module.compute.worker_private_ips
}

output "cp_instance_ids" {
  description = "Map of control plane node key to instance ID (needed for SSM)."
  value       = module.compute.cp_instance_ids
}

output "worker_instance_ids" {
  description = "Map of worker node key to instance ID (needed for SSM)."
  value       = module.compute.worker_instance_ids
}

output "vpc_id" {
  value = module.vpc.vpc_id
}
