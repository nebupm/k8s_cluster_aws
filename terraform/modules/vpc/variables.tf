variable "cluster_name" {
  description = "Cluster name — used for VPC resource names and tags."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC. Must be unique per cluster when clusters share an AWS account."
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones to span subnets across."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets — one per availability zone."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets — one per availability zone."
  type        = list(string)
}
