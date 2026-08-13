terraform {
  required_version = ">= 1.13.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    # Populated per cluster at init time:
    # terraform init -backend-config=backends/<team>-<env>.hcl
    use_lockfile = true
  }
}
