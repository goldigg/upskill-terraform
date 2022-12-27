output "alb_sg" {
  value = aws_security_group.alb_sg.id
}
output "lb_dns_name" {
  value = module.alb.lb_dns_name
}
output "target_group_arns" {
  value = module.alb.target_group_arns
}