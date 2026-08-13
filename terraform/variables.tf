variable "cluster_name" {
  type        = string
  description = "Unique name for this Kubernetes cluster (e.g. ntegra-payments-prod)."
}

variable "environment" {
  type        = string
  description = "Deployment environment."

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "team" {
  type        = string
  description = "Team or function that owns this cluster (e.g. payments, platform)."
}

variable "aws_region" {
  type        = string
  description = "AWS region to deploy into."
}

variable "aws_profile" {
  type        = string
  default     = null
  description = "Local AWS SSO profile. Set to null in CI/CD pipelines."
}

variable "assume_role_arn" {
  type        = string
  default     = null
  description = "IAM role ARN to assume for multi-account deployments. Null uses default credentials."
}

variable "availability_zones" {
  type        = list(string)
  description = "List of AZs to deploy nodes across."
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC. Must be unique per cluster when deploying in the same account."
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets (one per AZ, used by ALB)."
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private subnets (one per AZ, used by nodes)."
}

variable "ssh_key_name" {
  type        = string
  description = "Name of the EC2 key pair for node access."
}

variable "ssh_allowed_cidr" {
  type        = string
  default     = "0.0.0.0/0"
  description = "CIDR allowed SSH access. Restrict to office/VPN IP in production."
}

variable "manager_nodes" {
  type = map(object({
    instance_type = string
    disk_size_gb  = number
    az_index      = number
  }))
  description = "Control plane node definitions. Key is a unique node ID. Add entries to scale out."
}

variable "worker_nodes" {
  type = map(object({
    instance_type = string
    disk_size_gb  = number
    az_index      = number
  }))
  description = "Worker node definitions. Key is a unique node ID. Add entries to scale out."
}

variable "tag_who" {
  type        = string
  description = "Tag: team or individual responsible for these resources."
}

variable "tag_what" {
  type        = string
  description = "Tag: what these resources are."
}

variable "tag_why" {
  type        = string
  description = "Tag: why these resources exist."
}
