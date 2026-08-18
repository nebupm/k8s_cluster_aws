variable "cluster_name" {
  description = "Cluster name — used for security group names and tags."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID in which to create the security groups."
  type        = string
}

# Restrict to a known IP range in production (e.g. your office CIDR or VPN).
variable "ssh_allowed_cidr" {
  description = "CIDR block permitted to reach nodes on port 22. Restrict to office/VPN range in staging and prod."
  type        = string
  default     = "0.0.0.0/0"
}
