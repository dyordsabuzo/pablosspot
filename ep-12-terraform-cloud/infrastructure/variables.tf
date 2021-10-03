variable "region" {
  default = "us-east-1"
}

variable "localstack" {
  default = {
      apigateway = "http://localhost:4566"
  }
}