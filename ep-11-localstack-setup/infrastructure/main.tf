resource "aws_lambda_function" "access_key_generator" {
  function_name    = "access-key-generator"
  role             = aws_iam_role.role.arn
  filename         = "access-key-generator.zip"
  handler          = "lambda_function.handler"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  runtime          = "python3.8"
  timeout          = 30
  tags             = local.tags

  dynamic "environment" {
    for_each = length(var.lambda_variables) > 0 ? [1] : []
    content {
      variables = var.lambda_variables
    }
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

resource "null_resource" "pip_install" {
  provisioner "local-exec" {
    command = "apk add --no-cache py-pip && pip install -r ./lambda/requirements.txt -t ./lambda/app/"
  }
}
