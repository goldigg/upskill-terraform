provider "aws" {
  region                   = "eu-central-1"
}
terraform {
  backend "s3" {
    encrypt        = true
    bucket = "ggoldmann-tf-state"
    key    = "path/to/my/key"
    region = "eu-central-1"
    dynamodb_table = "ggoldmann-terraform-state-lock"
  }
}
