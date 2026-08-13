variable "environment" {
  type        = string
  description = "Environment tier for this state bucket: dev, staging, or prod. Must match the active Terraform workspace."

  validation {
    condition     = var.environment == terraform.workspace
    error_message = "Mismatch: var.environment='${var.environment}' but active workspace is '${terraform.workspace}'. Select the correct workspace first."
  }
}

variable "aws_region" {
  type        = string
  description = "AWS region for the state bucket."
  default     = "eu-west-2"
}

variable "aws_profile" {
  type        = string
  default     = null
  description = "Local AWS SSO profile. Set to null in CI/CD pipelines."
}

variable "force_destroy" {
  type        = bool
  default     = false
  description = "Allow bucket deletion with objects inside. Set true only for dev/test."
}

variable "enable_versioning" {
  type        = bool
  default     = true
  description = "Enable S3 versioning on the state bucket."
}

variable "enable_encryption" {
  type        = bool
  default     = true
  description = "Enable AES256 server-side encryption on the state bucket."
}

variable "tag_who" {
  type        = string
  description = "Tag: team or individual responsible for these resources."
}

variable "tag_what" {
  type        = string
  default     = "terraform-state"
  description = "Tag: what these resources are."
}

variable "tag_why" {
  type        = string
  default     = "k8s-cluster-state-storage"
  description = "Tag: why these resources exist."
}
