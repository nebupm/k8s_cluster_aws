variable "environment" {
  type        = string
  description = "(Required) Environment of all resources"
}

variable "prefix" {
  type        = string
  description = "(Required) Prefix to use for all resources in this module."
}

variable "aws_region" {
  type        = string
  description = "(Optional) AWS Region to deploy in. Defaults to us-east-1."
}

#variable "aws_profile" {
#  type        = string
#  description = "(Optional) AWS Profile to use for authentication. Defaults to 'default'."
#}

variable "vpc_address_range" {
  type        = string
  description = "Address range for the VPC"
}

variable "vpc_public_subnet_ranges" {
  type        = list(string)
  description = "List of public subnet CIDR ranges for the VPC"
}

variable "tag_who" {
  type        = string
  description = "Tag for who is responsible for the resources"
}

variable "tag_what" {
  type        = string
  description = "Tag for what the resources are"
}

variable "tag_why" {
  type        = string
  description = "Tag for why the resources exist"
}
