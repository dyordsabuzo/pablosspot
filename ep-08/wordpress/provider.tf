provider "aws" {
  region = var.region
}

provider "cloudflare" {
  email     = data.aws_ssm_parameter.cloudflare_email.value
  api_token = data.aws_ssm_parameter.cloudflare_token.value
}
