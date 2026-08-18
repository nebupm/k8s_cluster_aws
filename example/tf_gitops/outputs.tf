output "vpc_id" {
  description = "Id of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_details" {
  description = "Details of the VPC"
  value = {
    region      = var.aws_region
    environment = var.environment
    id          = module.vpc.vpc_id
  }
}
