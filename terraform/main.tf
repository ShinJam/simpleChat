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

# https://www.terraform.io/docs/language/values/locals.html
locals {
  name = "kuve"
  # Name, TerraformPath, VPC, Creator 추가 필요
  common_tags = {
    TerraformManaged : true,
    Environment : var.environment
    Project : "kuve"
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
# EC2
###################################
locals {
  ec2 = {
    key_name = "kuve-ec2"

  }
}
module "ec2" {
  source = "./modules/ec2"

  name = "api-server"

  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = local.ec2.key_name

  sg_ids    = tolist([module.sg.ec2_security_group_id, ])
  subnet_id = module.vpc.public_subnets[0]

  tags = local.common_tags
}

# Bastion
module "bastion_server" {
  source = "./modules/bastion"

  name            = "bastion"
  ami             = var.ami_id
  security_groups = tolist([module.sg.bastion_security_group_id, ])
  subnets         = module.vpc.public_subnets
  vpc_id          = module.vpc.vpc_id
  tags            = local.common_tags
  key_name        = local.ec2.key_name
}
