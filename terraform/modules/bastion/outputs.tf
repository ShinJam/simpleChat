output "this_bastion_public_eip" {
  value = aws_eip.bastion.public_ip
}
