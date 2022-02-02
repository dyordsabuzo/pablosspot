data "aws_caller_identity" "current" {}
data "aws_ecr_authorization_token" "token" {}

data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "permissions" {
  statement {
    actions = [
      "iam:CreateAccessKey",
      "iam:DeleteAccessKey",
      "iam:ListAccessKeys",
      "iam:UpdateAccessKey"
    ]
    resources = [aws_iam_user.user.arn]
  }

  statement {
    actions   = ["ssm:PutParameter"]
    resources = ["arn:aws:ssm:${var.region}:*:parameter/*testuser*"]
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

data "aws_ecr_repository" "repo" {
  name = var.repository_name
}
