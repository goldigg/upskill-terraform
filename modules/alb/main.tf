locals {
  name = "alb"
}
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = "${var.prefix}-alb"

  load_balancer_type = "application"
  vpc_id             = var.vpc_id
  subnets            = var.subnets

  security_groups = [aws_security_group.alb_sg.id]

  target_groups = var.target_groups

  http_tcp_listeners = var.http_tcp_listeners

  http_tcp_listener_rules = var.http_tcp_listener_rules

  tags = {
    Name  = "${var.prefix}-${local.name}"
    Owner = "${var.prefix}"
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "${var.prefix}-${local.name}-sg"
  description = "ALB SG"
  vpc_id      = var.vpc_id

  ingress {
    description = local.name
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = local.name
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    
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