provider "aws" {
  region                      = var.region
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  s3_force_path_style         = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    apigateway       = "http://localstack:4566"
    cloudformation   = "http://localstack:4566"
    cloudwatch       = "http://localstack:4566"
    cloudwatchevents = "http://localstack:4566"
    dynamodb         = "http://localstack:4566"
    ec2              = "http://localstack:4566"
    es               = "http://localstack:4566"
    firehose         = "http://localstack:4566"
    iam              = "http://localstack:4566"
    kinesis          = "http://localstack:4566"
    lambda           = "http://localstack:4566"
    route53          = "http://localstack:4566"
    redshift         = "http://localstack:4566"
    s3               = "http://localstack:4566"
    secretsmanager   = "http://localstack:4566"
    ses              = "http://localstack:4566"
    sns              = "http://localstack:4566"
    sqs              = "http://localstack:4566"
    ssm              = "http://localstack:4566"
    stepfunctions    = "http://localstack:4566"
    sts              = "http://localstack:4566"
  }
}
