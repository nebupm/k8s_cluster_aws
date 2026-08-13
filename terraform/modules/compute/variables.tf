variable "cluster_name" {
  type = string
}

variable "manager_nodes" {
  type = map(object({
    instance_type = string
    disk_size_gb  = number
    az_index      = number
  }))
}

variable "worker_nodes" {
  type = map(object({
    instance_type = string
    disk_size_gb  = number
    az_index      = number
  }))
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "sg_cp_id" {
  type = string
}

variable "sg_worker_id" {
  type = string
}

variable "key_name" {
  type = string
}

variable "instance_profile_name" {
  type = string
}
