variable "prefix" {}
variable "vpc_id" {
  type = string
}
variable "subnets" {}

variable "engine" {}
variable "engine_version" {}
variable "instance_class" {}
variable "instances" {}

variable "database_name" {}
variable "master_password" {}
variable "master_username" {}

variable "allowed_security_groups" {}
variable "snapshot_identifier" {}


