data "aws_iam_policy_document" "ecs_task_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}


data "aws_ssm_parameter" "dbname" {
  name  = "/app/wordpress/DATABASE_NAME"
}

data "aws_ssm_parameter" "dbuser" {
  name  = "/app/wordpress/DATABASE_MASTER_USERNAME"
}

data "aws_ssm_parameter" "dbpassword" {
  name  = "/app/wordpress/DATABASE_MASTER_PASSWORD"
}

data "aws_ssm_parameter" "dbhost" {
  name  = "/app/wordpress/DATABASE_HOST"
}