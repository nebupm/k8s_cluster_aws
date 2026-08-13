provider "aws" {
  region  = var.aws_region
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
