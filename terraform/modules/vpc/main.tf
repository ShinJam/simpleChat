# https://github.com/terraform-aws-modules/terraform-aws-vpc
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.11.3"

  name = var.name
  cidr = var.cidr

  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  database_subnets = var.database_subnets

  # rds 모듈로 rds 생성시 subnet_group가 이미 존재한다는 에러 발생
  # create_database_subnet_group = false

  enable_nat_gateway = true
  single_nat_gateway = true
}
