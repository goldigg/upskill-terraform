variable "prefix" {}
variable "vpc_id" {
  type = string
}
variable "subnets" {}
variable "target_groups" {}
variable "http_tcp_listeners" {}
variable "http_tcp_listener_rules" {}
