terraform {
  required_version = ">= 1.13.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
  default_tags {
    tags = {
      Who         = var.tag_who
      What        = var.tag_what
      Why         = var.tag_why
      Environment = var.environment
    }
  }
}
