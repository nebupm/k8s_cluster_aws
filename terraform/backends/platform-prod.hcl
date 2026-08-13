key    = "platform/prod/terraform.tfstate"
bucket = "REPLACE_AFTER_BOOTSTRAP"   # output of: terraform -chdir=bootstrap output state_bucket_name (prod workspace)
region = "eu-west-2"
# profile = "ntegra-sso-adm"
