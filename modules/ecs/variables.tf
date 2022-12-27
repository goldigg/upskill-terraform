variable "prefix" {}
variable "vpc_id" {
  type = string
}
variable "subnets" {}

variable "cpu" {
  default = 512
  type    = number
}
variable "memory" {
  default = 1024
  type    = number
}
variable "db_config" {
  type = object({
    dbHost     = string
    dnName     = string
    dbPassword = string
    dbUsername = string
  })
}
variable "port" {

}
variable "desired_count" {
}
variable "alb_security_groups" {}
variable "bastion_security_groups" {}
variable "alb_target_group_arns" {}

variable "web_image" {}
variable "s3_image" {}

variable "web_endpoint" {
  
}


