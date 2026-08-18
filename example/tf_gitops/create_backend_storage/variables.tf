#This is created outside the gitops process. You need to ensure that the bucket is created before you run the gitops process. The bucket name is passed to the gitops process as a variable.
#The required variables are defined here. The optional variables have default values defined here. You can override the default values in the environment specific tfvars files.
# The Variables are defined here for the backend storage creation module. These are initialised in ../environments/dev.tfvars or staging.tfvars and so on.

variable "environment" {
  type        = string
  description = "Environment for resources, Must match the active terraform workspace name"

  validation {
    # This rule guarantees execution stops if workspace != Environment. This is to avoid accidental resource creation in the wrong environment.
    condition     = var.environment == terraform.workspace
    error_message = "Mismatched Environment! You are using the '${var.environment}.tfvars' file but your active Terraform workspace is set to '${terraform.workspace}'."
  }
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
}

variable "aws_profile" {
  type        = string
  default     = null # Allows GitOps to run safely without this variable set
  description = "Local AWS SSO profile. Automatically bypassed in GitOps pipelines."
}

variable "prefix" {
  description = "Prefix for resources"
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket to be created for terraform state storage"
  type        = string
  default     = "terraform-state"
}

variable "force_destroy" {
  description = "Allow bucket deletion with objects inside (dangerous for prod)"
  type        = bool
}

variable "enable_versioning" {
  description = "Enable S3 versioning"
  type        = bool
  default     = true
}

variable "enable_encryption" {
  description = "Enable server side encryption"
  type        = bool
  default     = true
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
