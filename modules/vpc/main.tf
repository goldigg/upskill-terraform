module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "${var.prefix}-vpc"
  cidr   = var.cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  manage_default_network_acl = var.manage_default_network_acl
  enable_nat_gateway         = var.enable_nat_gateway
  single_nat_gateway = true
  one_nat_gateway_per_az = false

  tags = {
    Owner = "${var.prefix}"
  }
}



