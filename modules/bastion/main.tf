locals {
  name = "bastion"
}
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "${var.prefix}-${local.name}"

  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.ggoldmann.key_name
  monitoring             = var.monitoring
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  subnet_id              = var.subnet_id

  tags = {
    Name  = "${var.prefix}-${local.name}"
    Owner = "${var.prefix}"
  }
}


resource "tls_private_key" "ggoldmann" {
  algorithm = var.algorithm
  rsa_bits  = var.rsa_bits
}

resource "aws_key_pair" "ggoldmann" {
  key_name   = "${var.prefix}-key"
  public_key = tls_private_key.ggoldmann.public_key_openssh
}

resource "aws_security_group" "bastion_sg" {
  name        = "${var.prefix}-${local.name}-sg"
  description = "Bastion SG"
  vpc_id      = var.vpc_id

  ingress {
    description     = local.name
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
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