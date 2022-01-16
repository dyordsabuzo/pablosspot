resource "aws_ecs_cluster" "cluster" {
  name = var.cluster_name
}

resource "aws_ecs_service" "service" {
  name = var.service_name
  cluster = aws_ecs_cluster.cluster.name
  launch_type = "EC2"
  task_definition = aws_ecs_task_definition.task.arn
  desired_count = 2

  load_balancer {
    container_name = "nginx"
    container_port = 80
    target_group_arn = var.target_group_arn
  }
}

resource "aws_ecs_task_definition" "task" {
  family = var.task_family
  network_mode = "bridge"
  requires_compatibilities = ["EC2"]
  execution_role_arn = aws_iam_role.task_role.arn

  dynamic "volume" {
    for_each = local.volume_mapping
    
    content {
        host_path = volume.value.host_path
        name = volume.value.name
    }
  }

  container_definitions = jsonencode([
      {
          name = "wordpress"
          image = "wordpress:latest"
          cpu = 512
          memory = 512
          essential = true
          environment = [
              {
                  name = "WORDPRESS_DB_HOST"
                  value = data.aws_ssm_parameter.dbhost.value
              },
              {
                  name = "WORDPRESS_DB_USER"
                  value = data.aws_ssm_parameter.dbuser.value
              },
              {
                  name = "WORDPRESS_DB_NAME"
                  value = data.aws_ssm_parameter.dbname.value
              }
          ]
          secrets = [
              {
                  name = "WORDPRESS_DB_PASSWORD"
                  valueFrom = data.aws_ssm_parameter.dbpassword.arn
              }
          ]
          logConfiguration = {
              logDriver = "awslogs"
              options = {
                  awslogs-region = var.region
                  awslogs-group = aws_cloudwatch_log_group.log.name
                  awslogs-stream-prefix = "wordpress"
              }
          }
      },
      {
          name = "nginx"
          image = "nginx:1.18-alpine"
          cpu = 10
          memory = 256
          essential = true
          portMappings = [
              {
                  containerPort = 80
                  hostPort = 80
              }
          ]
          command = "/bin/sh -c 'nginx -s reload; nginx -g \"daemon off;\"'"
          mountPoints = [ for v in local.volume_mapping : {
              sourceVolume = v.name
              containerPath = v.containerPath
              readOnly = v.readOnly
          }]
          logConfiguration = {
              logDriver = "awslogs"
              options = {
                  awslogs-region = var.region
                  awslogs-group = aws_cloudwatch_log_group.log.name
                  awslogs-stream-prefix = "ngix"
              }
          }
      }
  ])
}

resource "aws_iam_role" "task_role" {
  name = "ecs-task-${var.task_family}-${terraform.workspace}"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_policy.json

  inline_policy {
    name = "ecs-task-permissions"
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = ["ecr:*"]
                Effects = "Allow"
                Resources = "*"
            }
        ]
    })
  }
}

resource "aws_cloudwatch_log_group" "log" {
  name = "/${var.cluster_name}/${var.service_name}"
  retention_in_days = 14
}