# https://github.com/terraform-aws-modules/terraform-aws-security-group#
module "ec2_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.8.0"

  name            = "ec2-sg"
  description     = "Security group for web-server with HTTP ports open within VPC"
  vpc_id          = var.vpc_id
#  use_name_prefix = "false"

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["https-443-tcp", "http-80-tcp", "ssh-tcp"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]

  tags = var.tags
}

# Allow SSH tunneling to RDS
module "bastion_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.17.0"

  name            = "bastion-sg"
  description     = "Allows SSH tunneling to RDS"
  vpc_id          = var.vpc_id
  use_name_prefix = "false"

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]

  tags = var.tags
}
