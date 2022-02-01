####################################
# Meta
####################################
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  cloud {
    organization = "kuve"

    workspaces {
      name = "staging"
    }
  }
}


####################################
# Provider
####################################
provider "aws" {
  region = var.region
}

###################################
# Security Group
###################################
module "sg" {
  source = "./modules/sg"

  vpc_id = module.vpc.vpc_id
  tags   = local.common_tags
}

###################################
# VPC
###################################
module "vpc" {
  source = "./modules/vpc"

  name = local.name
  cidr = var.cidr

  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  tags = local.common_tags
}

###################################
# ALB
###################################
module "alb" {
  source = "./modules/alb"

  name = format("%s-alb", local.name)

  vpc_id                  = module.vpc.vpc_id
  security_groups         = tolist([module.sg.ec2_security_group_id, ])
  subnets                 = module.vpc.public_subnets
  http_tcp_listeners      = local.alb.http_tcp_listeners
  http_tcp_listener_rules = local.alb.http_tcp_listener_rules
  target_groups           = local.alb.target_groups

  tags = local.common_tags
}

######################################
# KMS: create kms for encrypting/decrypting SSM parameter stores
######################################
module "kms" {
  source = "./modules/kms"

  name = local.name

  jenkins_role_arn = aws_iam_role.jenkins_role.arn

  tags       = local.common_tags
  depends_on = [aws_iam_role.jenkins_role]
}

###################################
# EC2
###################################

# API-Server
module "api-server" {
  source = "./modules/ec2"

  name = "api-server"

  ami           = var.ami_id
  instance_type = var.server_instance_type
  key_name      = local.ec2.key_name

  sg_ids    = tolist([module.sg.ec2_security_group_id, ])
  subnet_id = element(module.vpc.private_subnets, 0)

  tags = local.common_tags
}

# Jenkins
module "jenkins" {
  source = "./modules/ec2"

  name = "jenkins-master"

  ami           = var.ami_id
  instance_type = var.jenkins_instance_type
  key_name      = local.ec2.key_name

  sg_ids                      = tolist([module.sg.ec2_jenkins_security_group_id, module.vpc.default_sg_id])
  subnet_id                   = element(module.vpc.private_subnets, 0)
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.jenkins.name

  user_data = data.cloudinit_config.init_jenkins.rendered

  tags = local.common_tags
}

# Bastion
module "bastion_server" {
  source = "./modules/bastion"

  name = "bastion"
  ami  = var.ami_id
  #  security_groups = tolist([module.sg.bastion_security_group_id, ])
  subnets  = module.vpc.public_subnets
  vpc_id   = module.vpc.vpc_id
  tags     = local.common_tags
  key_name = local.ec2.key_name
}

###################################
# ECR
###################################
resource "aws_ecr_repository" "fiber" {
  name = "fiber"
}
