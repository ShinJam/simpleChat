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

resource "aws_instance" "api-server" {
  ami           = var.image_id
  instance_type = "t2.nano"

  tags = {
    Name = local.common_tags.Environment
  }
}

