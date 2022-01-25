# https://github.com/cloudposse/terraform-aws-ec2-bastion-server
module "bastion" {
  source  = "cloudposse/ec2-bastion-server/aws"
  version = "0.21.0"

  name            = var.name
  ami             = var.ami
  security_groups = var.security_groups
  subnets         = var.subnets
  vpc_id          = var.vpc_id
  ssh_user        = "ec2user"
  key_name        = var.key_name
  tags            = var.tags
}

resource "aws_eip" "bastion" {
  instance = module.bastion.instance_id
  vpc      = true
  tags     = var.tags
}
