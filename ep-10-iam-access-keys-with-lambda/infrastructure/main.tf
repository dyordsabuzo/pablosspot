resource "aws_lambda_function" "access_key_generator" {
  function_name = "access-key-generator"
  role          = aws_iam_role.role.arn
  image_uri     = docker_registry_image.image.name
  package_type  = "Image"
  timeout       = 30
  tags          = local.tags

  image_config {
    entry_point = ["/usr/local/bin/python", "-m", "awslambdaric"]
  }
}

resource "aws_iam_role" "role" {
  name               = "access-key-generator-role"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

resource "aws_iam_role_policy" "permissions" {
  name   = "access-key-generator-policy"
  role   = aws_iam_role.role.id
  policy = data.aws_iam_policy_document.permissions.json
}

resource "aws_iam_user" "user" {
  name = "testuser"
  path = "/system/"
  tags = local.tags
}

resource "aws_cloudwatch_event_rule" "rule" {
  name                = "CreateAccessKey"
  description         = "Create New Access key"
  schedule_expression = var.schedule_expression
}

resource "aws_cloudwatch_event_target" "target" {
  arn   = aws_lambda_function.access_key_generator.arn
  rule  = aws_cloudwatch_event_rule.rule.id
  input = <<-EOF
      {
        "user": "testuser",
        "region": "${var.region}"
      }
    EOF
}

resource "aws_lambda_permission" "permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.access_key_generator.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.rule.arn
}

resource "docker_registry_image" "image" {
  name = "${data.aws_ecr_repository.repo.repository_url}:${var.image_tag}"

  build {
    context = "../lambda"
  }
}
