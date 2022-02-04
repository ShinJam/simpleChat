# https://github.com/terraform-aws-modules/terraform-aws-security-group#
module "ec2_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.8.0"

  name        = "ec2-sg"
  description = "Security group for web-server with HTTP ports open within VPC"
  vpc_id      = var.vpc_id
  #  use_name_prefix = "false"

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["https-443-tcp", "http-80-tcp", "http-8080-tcp", "ssh-tcp"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]

  tags = var.tags
}

module "jenkins_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.8.0"

  name        = "jenkins-sg"
  description = "Security group for jenkins with HTTP 8080 ports open within VPC"
  vpc_id      = var.vpc_id
  #  use_name_prefix = "false"

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-8080-tcp", "ssh-tcp"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]

  tags = var.tags
}

module "rds_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.8.0"

  name            = "rds-sg"
  description     = "Allows inbound access from api-server only"
  vpc_id          = var.vpc_id
  use_name_prefix = "false"

  # https://github.com/terraform-aws-modules/terraform-aws-security-group#note-about-value-of-count-cannot-be-computed
  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "postgresql-tcp"
      source_security_group_id = module.ec2_sg.security_group_id
    },
    {
      rule                     = "postgresql-tcp"
      source_security_group_id = module.bastion_sg.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 2

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]

  tags = var.tags
}

# Allow SSH tunneling to RDS
module "bastion_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.8.0"

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

# redis(elasticache)
module "redis_sg" {
  # using submodule makes ingress_cidr_blocks required
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.8.0"

  name            = "redis-sg"
  description     = "Allows inbound access from ECS and Bastion only"
  vpc_id          = var.vpc_id
  use_name_prefix = "false"

  # https://github.com/terraform-aws-modules/terraform-aws-security-group#note-about-value-of-count-cannot-be-computed
  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "redis-tcp"
      source_security_group_id = module.ec2_sg.security_group_id
    },
    {
      rule                     = "redis-tcp"
      source_security_group_id = module.bastion_sg.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 2

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]

  tags = var.tags
}
