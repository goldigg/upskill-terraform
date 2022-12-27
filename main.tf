locals{
    prefix = "ggoldmann"
}
module "vpc" {
  source          = "./modules/vpc"
  prefix          = local.prefix
  azs             = ["eu-central-1a", "eu-central-1b"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24", "10.0.21.0/24", "10.0.22.0/24"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
}
module "bastion" {
  source = "./modules/bastion"
  prefix = local.prefix

  ami           = "ami-076309742d466ad69"
  instance_type = "t2.micro"
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.public_subnets[0]

}

module "cluster" {
  source = "./modules/aurora"
  prefix = local.prefix

  engine         = "aurora-postgresql"
  engine_version = "13.7"
  instance_class = "db.t3.medium"

  instances = {
    one = {}
    two = {}
  }

  vpc_id                  = module.vpc.vpc_id
  subnets                 = [module.vpc.private_subnets[2], module.vpc.private_subnets[3]]
  allowed_security_groups = [module.ecs.ecs_sg]

  database_name   = "postgres"
  master_password = "postgres"
  master_username = "postgres"
  snapshot_identifier = "ggoldmann-db-snap"
}

module "ecs" {
  source = "./modules/ecs"
  prefix = local.prefix

  web_image = "public.ecr.aws/ablachowicz-public-ecr-reg/ggoldmann_db_web:${var.web_hash}"
  s3_image  = "public.ecr.aws/ablachowicz-public-ecr-reg/ggoldmann_s3_web:${var.s3_hash}"
  db_config = {
    dbHost     = module.cluster.cluster_endpoint
    dnName     = "postgres"
    dbPassword = "postgres"
    dbUsername = "postgres"
  }
  web_endpoint = "${module.alb.lb_dns_name}"

  port          = 5000
  desired_count = 3

  vpc_id        = module.vpc.vpc_id
  subnets                 = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]
  alb_security_groups     = [module.alb.alb_sg]
  bastion_security_groups = [module.bastion.bastion_sg]
  alb_target_group_arns = module.alb.target_group_arns
}

module "alb" {
  source = "./modules/alb"
  prefix = local.prefix


  vpc_id  = module.vpc.vpc_id
  subnets = [module.vpc.public_subnets[0], module.vpc.public_subnets[1]]

  target_groups = [
    {
      name_prefix      = "web-"
      backend_protocol = "HTTP"
      backend_port     = 5000
      target_type      = "ip"
      health_check = {
        path = "/health"
      }
    },
    {
      name_prefix      = "s3-"
      backend_protocol = "HTTP"
      backend_port     = 5000
      target_type      = "ip"
      health_check = {
        path = "/health"
      }
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  http_tcp_listener_rules = [
    {
      actions = [{
        type               = "forward"
        target_group_index = 1

      }]
      conditions = [{
      path_patterns = ["/upload", "/s3"] }]
      priority = 1
    }
  ]
}