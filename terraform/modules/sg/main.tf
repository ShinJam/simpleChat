# https://github.com/terraform-aws-modules/terraform-aws-security-group#
module "ec2_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.8.0"

  name            = "ec2-sg"
  description     = "Security group for web-server with HTTP ports open within VPC"
  vpc_id          = var.vpc_id
  use_name_prefix = "false"

  ingress_cidr_blocks = ["0.0.0.0/0"]

  tags = var.tags
}
