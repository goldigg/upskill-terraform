locals {
  name = "ecs"
}

module "ecs" {
  source       = "terraform-aws-modules/ecs/aws"
  cluster_name = "${var.prefix}-${local.name}-fargate"
}
resource "aws_ecs_task_definition" "web" {
  family                   = "${var.prefix}-web-tf"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  execution_role_arn="arn:aws:iam::890769921003:role/ecsTaskExecutionRole"
  memory                   = var.memory
  container_definitions = jsonencode([
    {
      name      = "${var.prefix}-web-tf"
      image     = var.web_image
      essential = true
  logConfiguration = {
    logDriver = "awslogs",
    options = {
                    "awslogs-group": "awslogs-ggoldmann-web",
                    "awslogs-region": "eu-central-1",
                    "awslogs-stream-prefix": "awslogs-ecs-ggoldmann",
                    "awslogs-create-group": "true"
                }
  }
      environment = [
        {
          "name" : "DB_HOST",
          "value" : "${var.db_config.dbHost}"
        },
        {
          "name" : "DB_NAME",
          "value" : "${var.db_config.dnName}"
        },
        {
          "name" : "DB_PASSWORD",
          "value" : "${var.db_config.dbPassword}"
        },
        {
          "name" : "DB_USERNAME",
          "value" : "${var.db_config.dbUsername}"
        }
      ]
      portMappings = [
        {
          containerPort = var.port
          hostPort      = var.port
        }
      ]
    }
  ])
}

resource "aws_security_group" "web" {
  name        = "${var.prefix}-${local.name}-sg"
  description = "Web SG"
  vpc_id      = var.vpc_id

  ingress {
    description     = "${local.name}-alb"
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = var.alb_security_groups
  }
  ingress {
    description     = "${local.name}-ssh"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = var.bastion_security_groups
  }
  egress {
    description = local.name
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.prefix}-${local.name}-sg"
  }
}

resource "aws_ecs_service" "web_svc" {
  name            = "${var.prefix}-web-db-tf"
  cluster         = module.ecs.cluster_arn
  task_definition = aws_ecs_task_definition.web.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnets
    security_groups = [aws_security_group.web.id]
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arns[0]
    container_name   = "${var.prefix}-web-tf"
    container_port   = var.port
  }
}

resource "aws_ecs_task_definition" "s3" {
  family                   = "${var.prefix}-s3-tf"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu                      = var.cpu
  memory                   = var.memory
  task_role_arn = "arn:aws:iam::890769921003:role/ggoldmannEcsTaskRole1"
  execution_role_arn="arn:aws:iam::890769921003:role/ecsTaskExecutionRole"
  container_definitions = jsonencode([
    {
      name      = "${var.prefix}-s3-tf"
      image     = var.s3_image
      essential = true
  logConfiguration = {
    logDriver = "awslogs",
    options = {
                    "awslogs-group": "awslogs-ggoldmann-s3",
                    "awslogs-region": "eu-central-1",
                    "awslogs-stream-prefix": "awslogs-ecs-ggoldmann",
                    "awslogs-create-group": "true"
                }
  }
      environment = [
        {
          "name" : "WEB_ENDPOINT",
          "value" : "http://${var.web_endpoint}/info"
        }
      ]
      portMappings = [
        {
          containerPort = var.port
          hostPort      = var.port
        }
      ]
    }
  ])
}


resource "aws_ecs_service" "s3_svc" {
  name            = "${var.prefix}-web-s3-tf"
  cluster         = module.ecs.cluster_arn
  task_definition = aws_ecs_task_definition.s3.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnets
    security_groups = [aws_security_group.web.id]
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arns[1]
    container_name   = "${var.prefix}-s3-tf"
    container_port   = var.port
  }
}