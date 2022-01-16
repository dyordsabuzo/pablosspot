resource "aws_rds_cluster" "wordpress" {
  cluster_identifier     = "wordpress-cluster"
  engine                 = "aurora-mysql"
  engine_version         = "5.7.mysql_aurora.2.07.1"
  availability_zones     = data.aws_availability_zones.zones.names
  database_name          = aws_ssm_parameter.dbname.value
  master_username        = aws_ssm_parameter.dbuser.value
  master_password        = aws_ssm_parameter.dbpassword.value
  db_subnet_group_name   = aws_db_subnet_group.dbsubnet.id
  engine_mode            = "serverless"
  vpc_security_group_ids = [aws_security_group.rds_secgrp.id]

  scaling_configuration {
    min_capacity = 1
    max_capacity = 2
  }

  tags = local.tags
}

resource "aws_ssm_parameter" "dbname" {
  name  = "/app/wordpress/DATABASE_NAME"
  type  = "String"
  value = var.database_name
}

resource "aws_ssm_parameter" "dbuser" {
  name  = "/app/wordpress/DATABASE_MASTER_USERNAME"
  type  = "String"
  value = var.database_master_username
}

resource "aws_ssm_parameter" "dbpassword" {
  name  = "/app/wordpress/DATABASE_MASTER_PASSWORD"
  type  = "SecureString"
  value = random_password.password.result
}

resource "aws_ssm_parameter" "dbhost" {
  name  = "/app/wordpress/DATABASE_HOST"
  type  = "String"
  value = aws_rds_cluster.wordpress.endpoint
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "aws_db_subnet_group" "dbsubnet" {
  name        = "wordpress-cluster-subnet"
  description = "Aurora wordpress cluster db subnet group"
  subnet_ids  = data.aws_subnet_ids.subnets.ids
  tags        = local.tags
}

resource "aws_security_group" "rds_secgrp" {
  name        = "wordpress rds access"
  description = "RDS secgroup"
  vpc_id      = var.vpc_id

  ingress {
    description = "VPC bound"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
  }

  tags = local.tags
}

resource "aws_instance" "wordpress" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.ec2_instance_type
  associate_public_ip_address = true
  subnet_id                   = sort(data.aws_subnet_ids.subnets.ids)[0]
  security_groups             = [aws_security_group.ec2_secgrp.id]
  iam_instance_profile        = "ec2_profile"
  user_data                   = data.template_file.userdata.rendered

  tags = merge(local.tags, {
    Name = "wordpress-isntance"
  })
}

resource "aws_security_group" "ec2_secgrp" {
  name        = "wordpress-instance-secgrp"
  description = "wordpress instance secgrp"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.wordpress_external_port
    to_port     = var.wordpress_external_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags

}

resource "cloudflare_record" "wp" {
  zone_id = data.cloudflare_zones.domain.zones[0].id
  name    = var.endpoint
  value   = aws_instance.wordpress.public_ip
  type    = "A"
  proxied = true
}
