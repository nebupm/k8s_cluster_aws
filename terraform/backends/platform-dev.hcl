key    = "platform/dev/terraform.tfstate"
bucket = "REPLACE_AFTER_BOOTSTRAP"   # output of: terraform -chdir=bootstrap output state_bucket_name (dev workspace)
region = "eu-west-2"
# The S3 backend picks up AWS_PROFILE from the environment automatically.
# For local SSO runs, set it before calling terraform init:
#   export AWS_PROFILE=ntegra-sso-adm && aws sso login --profile ntegra-sso-adm
# Do not hardcode the profile here — CI/CD runners use an IAM role instead.
