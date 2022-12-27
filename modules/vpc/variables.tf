variable "prefix" {}
variable "cidr" {
  type    = string
  default = "10.0.0.0/16"
}
variable "azs" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}
variable "public_subnets" {
  type = list(string)
}
variable "manage_default_network_acl" {
  type    = bool
  default = false
}
variable "enable_nat_gateway" {
  type    = bool
  default = true
}
