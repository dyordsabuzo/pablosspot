variable "region" {
  default = "us-east-1"
}

variable "localstack" {
  default = {
    apigateway = "http://localhost:4566"
  }
}

variable "vault_address" {
  description = "Vault url address"
  type        = string
  default     = "http://localhost:32648"
}
