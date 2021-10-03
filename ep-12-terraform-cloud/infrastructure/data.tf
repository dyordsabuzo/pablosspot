data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "./lambda/app"
  output_path = "access-key-generator.zip"
  depends_on  = [null_resource.dependencies]
}
