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
