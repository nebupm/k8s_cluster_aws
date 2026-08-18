cluster_name    = "ntegra-platform-prod"
environment     = "prod"
team            = "platform"
aws_region      = "eu-west-2"
aws_profile     = null
assume_role_arn = null # e.g. "arn:aws:iam::111122223333:role/TerraformRole" for prod account

availability_zones   = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
vpc_cidr             = "10.2.0.0/16"
public_subnet_cidrs  = ["10.2.0.0/24", "10.2.1.0/24", "10.2.2.0/24"]
private_subnet_cidrs = ["10.2.10.0/24", "10.2.11.0/24", "10.2.12.0/24"]

ssh_allowed_cidr = "10.0.0.0/8"

manager_nodes = {
  "1" = { instance_type = "t3.medium", disk_size_gb = 50, az_index = 0 }
  "2" = { instance_type = "t3.medium", disk_size_gb = 50, az_index = 1 }
  "3" = { instance_type = "t3.medium", disk_size_gb = 50, az_index = 2 }
}

worker_nodes = {
  "1" = { instance_type = "t3.xlarge", disk_size_gb = 200, az_index = 0 }
  "2" = { instance_type = "t3.xlarge", disk_size_gb = 200, az_index = 1 }
  "3" = { instance_type = "t3.xlarge", disk_size_gb = 200, az_index = 2 }
}

tag_who  = "platform-team"
tag_what = "k8s-cluster"
tag_why  = "platform-services-prod"
