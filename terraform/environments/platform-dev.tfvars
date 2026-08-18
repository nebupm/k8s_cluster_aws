cluster_name    = "ntegra-platform-dev"
environment     = "dev"
team            = "platform"
aws_region      = "eu-west-2"
aws_profile     = null # set to your SSO profile for local runs, e.g. "ntegra-sso-adm"
assume_role_arn = null # set to cross-account role ARN for multi-account deployments

availability_zones   = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]

ssh_allowed_cidr = "0.0.0.0/0"

manager_nodes = {
  "1" = { instance_type = "t3.medium", disk_size_gb = 50, az_index = 0 }
}

worker_nodes = {
  "1" = { instance_type = "t3.medium", disk_size_gb = 50, az_index = 0 }
  "2" = { instance_type = "t3.medium", disk_size_gb = 50, az_index = 1 }
}

tag_who  = "platform-team"
tag_what = "k8s-cluster"
tag_why  = "platform-services-dev"
