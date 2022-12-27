output "private_key" {
  value     = module.bastion.private_key
  sensitive = true
}