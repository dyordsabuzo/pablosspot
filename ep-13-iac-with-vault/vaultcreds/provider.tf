provider "vault" {
  address = var.vault_address
  token   = data.aws_ssm_parameter.token.value
}

provider "aws" {
  region = var.region
}
