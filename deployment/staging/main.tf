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
}

# terraform {
#   backend "remote" {
#     organization = "mspw"

#     workspaces {
#       name = "alyke-staging"
#     }
#   }
# }

# https://www.terraform.io/docs/language/values/locals.html
# locals {
#   # Name, TerraformPath, VPC, Creator 추가 필요
#   common_tags = {
#     TerraformManaged : true,
#     Environment : var.environment
#     Project : var.name
#     Team : "developers"
#   }
# }

####################################
# Provider
####################################
provider "aws" {
  alias  = "seoul"
  region = var.region
}


resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "staging"
  }
}
