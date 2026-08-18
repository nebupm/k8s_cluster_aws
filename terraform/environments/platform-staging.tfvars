cluster_name    = "ntegra-platform-staging"
environment     = "staging"
team            = "platform"
aws_region      = "eu-west-2"
aws_profile     = "ntegra-sb-sso-adm"
assume_role_arn = null

availability_zones   = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
vpc_cidr             = "10.1.0.0/16"
public_subnet_cidrs  = ["10.1.0.0/24", "10.1.1.0/24", "10.1.2.0/24"]
private_subnet_cidrs = ["10.1.10.0/24", "10.1.11.0/24", "10.1.12.0/24"]

ssh_allowed_cidr = "10.0.0.0/8"

manager_nodes = {
  "1" = { instance_type = "t3.medium", disk_size_gb = 50, az_index = 0 }
  "2" = { instance_type = "t3.medium", disk_size_gb = 50, az_index = 1 }
  "3" = { instance_type = "t3.medium", disk_size_gb = 50, az_index = 2 }
}

worker_nodes = {
  "1" = { instance_type = "t3.large", disk_size_gb = 100, az_index = 0 }
  "2" = { instance_type = "t3.large", disk_size_gb = 100, az_index = 1 }
}

tag_who  = "platform-team"
tag_what = "k8s-cluster"
tag_why  = "platform-services-staging"
