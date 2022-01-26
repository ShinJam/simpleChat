output "public_eip" {
  value = module.bastion.public_ip
}

output "instance_id" {
  value = module.bastion.instance_id
}
