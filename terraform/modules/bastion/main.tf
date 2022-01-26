# https://github.com/cloudposse/terraform-aws-ec2-bastion-server
module "bastion" {
  source  = "cloudposse/ec2-bastion-server/aws"
  version = "0.27.0"

  name = var.name
  #  security_groups = var.security_groups
  subnets  = var.subnets
  vpc_id   = var.vpc_id
  ssh_user = "ec2user"
  key_name = var.key_name

  associate_public_ip_address = true

  tags = var.tags
}
