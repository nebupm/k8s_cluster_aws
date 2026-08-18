variable "cluster_name" {
  description = "Cluster name — used for load balancer resource names and tags."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID in which to create the load balancers and target groups."
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the internet-facing ALB."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the internal API NLB."
  type        = list(string)
}

variable "sg_alb_id" {
  description = "Security group ID to attach to the ALB."
  type        = string
}

variable "cp_instance_ids" {
  description = "Map of control plane instance IDs for NLB target group registration."
  type        = map(string)
}

variable "worker_instance_ids" {
  description = "Map of worker instance IDs for ALB target group registration."
  type        = map(string)
}
