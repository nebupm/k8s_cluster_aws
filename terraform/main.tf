module "vpc" {
  source = "./modules/vpc"

  cluster_name         = var.cluster_name
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "security_groups" {
  source = "./modules/security_groups"

  cluster_name     = var.cluster_name
  vpc_id           = module.vpc.vpc_id
  ssh_allowed_cidr = var.ssh_allowed_cidr
}

module "iam" {
  source = "./modules/iam"

  cluster_name = var.cluster_name
}

module "compute" {
  source = "./modules/compute"

  cluster_name          = var.cluster_name
  manager_nodes         = var.manager_nodes
  worker_nodes          = var.worker_nodes
  private_subnet_ids    = module.vpc.private_subnet_ids
  sg_cp_id              = module.security_groups.sg_cp_id
  sg_worker_id          = module.security_groups.sg_worker_id
  key_name              = var.ssh_key_name
  instance_profile_name = module.iam.instance_profile_name
}

module "load_balancer" {
  source = "./modules/load_balancer"

  cluster_name        = var.cluster_name
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.public_subnet_ids
  private_subnet_ids  = module.vpc.private_subnet_ids
  sg_alb_id           = module.security_groups.sg_alb_id
  cp_instance_ids     = module.compute.cp_instance_ids
  worker_instance_ids = module.compute.worker_instance_ids
}
