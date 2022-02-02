output "public_eip" {
  value = module.bastion.public_ip
}

output "instance_id" {
  value = module.bastion.instance_id
}

output "security_group_id" {
  value       = module.bastion.security_group_id
  description = "Bastion host Security Group ID"
}
