provider "aws" {
  region = var.aws_region

  # Authentication for API calls (terraform plan/apply).
  # - Local SSO runs: set AWS_PROFILE env var before running terraform.
  #   The provider picks it up automatically when aws_profile is null.
  #   export AWS_PROFILE=ntegra-sso-adm && aws sso login --profile ntegra-sso-adm
  # - Explicit profile override: set aws_profile in the cluster's .tfvars.
  # - CI/CD: leave aws_profile null — the runner's IAM role is used instead.
  # NOTE: aws_profile covers provider auth only. The S3 backend (terraform init)
  # authenticates separately and also picks up AWS_PROFILE from the environment.
  profile = var.aws_profile

  dynamic "assume_role" {
    for_each = var.assume_role_arn != null ? [1] : []
    content {
      role_arn = var.assume_role_arn
    }
  }

  default_tags {
    tags = {
      Cluster     = var.cluster_name
      Environment = var.environment
      Team        = var.team
      ManagedBy   = "terraform"
      Who         = var.tag_who
      What        = var.tag_what
      Why         = var.tag_why
    }
  }
}
