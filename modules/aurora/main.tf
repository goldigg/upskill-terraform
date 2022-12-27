locals {
  name = "postgres"
}

module "cluster" {
  source = "terraform-aws-modules/rds-aurora/aws"

  name           = "${var.prefix}-aurora-db-postgres"
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  instances = var.instances

  vpc_id  = var.vpc_id
  subnets = var.subnets

  vpc_security_group_ids = [aws_security_group.db_sg.id]
  create_security_group  = false

  database_name   = var.database_name
  master_password = var.master_password
  master_username = var.master_username

  create_random_password = false
  apply_immediately      = true
  snapshot_identifier = var.snapshot_identifier	


  tags = {
    Name  = "${var.prefix}-${local.name}"
    Owner = "${var.prefix}"
  }
}

resource "aws_security_group" "db_sg" {
  name        = "${var.prefix}-${local.name}-sg"
  description = "DB SG"
  vpc_id      = var.vpc_id

  ingress {
    description     = local.name
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.allowed_security_groups
  }
  tags = {
    Name = "${var.prefix}-${local.name}-sg"
  }
}

