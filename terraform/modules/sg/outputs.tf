output "ec2_security_group_id" {
  description = "The ID of the security group"
  value       = module.ec2_sg.security_group_id
}
output "bastion_security_group_id" {
  description = "The ID of the security group"
  value       = module.bastion_sg.this_security_group_id
}
