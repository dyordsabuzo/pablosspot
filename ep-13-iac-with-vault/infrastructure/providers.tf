provider "vault" {
  address = var.vault_address
}

provider "aws" {
  region     = var.region
  access_key = data.vault_aws_access_credentials.aws.access_key
  secret_key = data.vault_aws_access_credentials.aws.secret_key
  token      = data.vault_aws_access_credentials.aws.security_token
}
