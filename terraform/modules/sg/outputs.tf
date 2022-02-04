output "ec2_security_group_id" {
  description = "The ID of the api server security group"
  value       = module.ec2_sg.security_group_id
}
output "ec2_jenkins_security_group_id" {
  description = "The ID of the jenkins security group"
  value       = module.jenkins_sg.security_group_id
}
output "bastion_security_group_id" {
  description = "The ID of the bastion security group"
  value       = module.bastion_sg.security_group_id
}

output "rds_security_group_id" {
  description = "The ID of the rds security group"
  value       = module.rds_sg.security_group_id
}
