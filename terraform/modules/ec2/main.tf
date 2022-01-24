# https://github.com/terraform-aws-modules/terraform-aws-ec2-instance
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = var.name

  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  monitoring             = true
  vpc_security_group_ids = var.sg_ids
  subnet_id              = var.subnet_id

  tags = var.tags
}

