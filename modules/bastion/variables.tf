variable "prefix" {}
variable "ami" {
  type = string
}
variable "instance_type" {
  type = string
}
variable "monitoring" {
  type    = bool
  default = false
}
variable "vpc_id" {
  type = string
}
variable "subnet_id" {
  type = string
}
variable "algorithm" {
  type    = string
  default = "RSA"
}
variable "rsa_bits" {
  type    = number
  default = 4096
}

