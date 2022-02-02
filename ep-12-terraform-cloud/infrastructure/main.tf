resource "aws_iam_role" "role" {
  name               = "access-key-generator-role"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

resource "null_resource" "dependencies" {
  provisioner "local-exec" {
    command = "pip install -r ./lambda/requirements.txt -t ./lambda/app/"
  }
}

resource "aws_lambda_function" "access_key_generator" {
  function_name    = "access-key-generator"
  role             = aws_iam_role.role.arn
  filename         = "access-key-generator.zip"
  handler          = "lambda_function.handler"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  runtime          = "python3.8"
  timeout          = 30
  tags             = local.tags
}
