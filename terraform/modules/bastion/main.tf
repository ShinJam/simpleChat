# https://github.com/cloudposse/terraform-aws-ec2-bastion-server
module "bastion" {
  source  = "cloudposse/ec2-bastion-server/aws"
  version = "0.28.5"

  name = var.name
  security_groups = var.security_groups
  subnets  = var.subnets
  vpc_id   = var.vpc_id
  key_name = var.key_name
  security_group_enabled = false

  associate_public_ip_address = true

  tags = var.tags
}
