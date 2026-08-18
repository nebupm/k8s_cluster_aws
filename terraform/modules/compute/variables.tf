variable "cluster_name" {
  description = "Cluster name — used for resource naming and tagging."
  type        = string
}

variable "manager_nodes" {
  description = "Map of control plane node definitions. Key is a short identifier; value specifies instance type, disk size, and AZ index."
  type = map(object({
    instance_type = string
    disk_size_gb  = number
    az_index      = number
  }))
}

variable "worker_nodes" {
  description = "Map of worker node definitions. Key is a short identifier; value specifies instance type, disk size, and AZ index."
  type = map(object({
    instance_type = string
    disk_size_gb  = number
    az_index      = number
  }))
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs — nodes are placed in these subnets by az_index."
  type        = list(string)
}

variable "sg_cp_id" {
  description = "Security group ID to attach to control plane instances."
  type        = string
}

variable "sg_worker_id" {
  description = "Security group ID to attach to worker instances."
  type        = string
}

variable "key_name" {
  description = "EC2 Key Pair name for SSH access — managed by the keys module."
  type        = string
}

variable "instance_profile_name" {
  description = "IAM instance profile name to attach to nodes (grants SSM access)."
  type        = string
}
