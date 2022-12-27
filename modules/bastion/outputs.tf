output "private_key" {
  value     = tls_private_key.ggoldmann.private_key_pem
  sensitive = true
}

output "bastion_sg" {
  value = aws_security_group.bastion_sg.id
}