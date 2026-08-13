variable "cluster_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

# Restrict to a known IP range in production (e.g. your office CIDR or VPN).
variable "ssh_allowed_cidr" {
  type    = string
  default = "0.0.0.0/0"
}
