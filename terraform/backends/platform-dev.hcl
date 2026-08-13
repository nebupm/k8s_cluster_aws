key    = "platform/dev/terraform.tfstate"
bucket = "REPLACE_AFTER_BOOTSTRAP"   # output of: terraform -chdir=bootstrap output state_bucket_name (dev workspace)
region = "eu-west-2"
# profile = "ntegra-sso-adm"         # uncomment for local runs
