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

  azs              = var.azs
  public_subnets   = var.public_subnets
  private_subnets  = var.private_subnets
  database_subnets = var.database_subnets

  tags = local.common_tags
  public_subnet_tags = {
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/elb"                                          = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"                                 = "1"
  }
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

  jenkins_role_arn = aws_iam_role.default_role.arn

  tags       = local.common_tags
  depends_on = [aws_iam_role.default_role]
}

###################################
# EC2
###################################

# API-Server
# module "api-server" {
#   source = "./modules/ec2"

#   name = "api-server"

#   ami           = var.ami_id
#   instance_type = var.server_instance_type
#   key_name      = local.ec2.key_name

#   sg_ids                      = tolist([module.sg.ec2_security_group_id, ])
#   subnet_id                   = element(module.vpc.private_subnets, 0)
#   associate_public_ip_address = false
#   iam_instance_profile        = aws_iam_instance_profile.api-server.name

#   user_data = data.template_file.api_userdata.rendered

#   tags = local.common_tags
# }

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

  user_data = data.template_file.jenkins_userdata.rendered

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

######################################
# RDS Postgresql
######################################
module "db" {
  source = "./modules/rds"

  name = format("%s-db", local.name)

  engine_version    = var.engine_version
  instance_class    = var.instance_class
  apply_immediately = var.apply_immediately

  database_name = var.database_name
  username      = var.username
  password      = var.password

  vpc_security_group_ids = tolist([module.sg.rds_security_group_id, ])
  subnet_ids             = module.vpc.database_subnets
  deletion_protection    = var.deletion_protection

  tags = local.common_tags
}


###################################
# ECR
###################################
resource "aws_ecr_repository" "fiber" {
  name = "fiber"
}

###################################
# elasticache - redis
###################################
module "redis" {
  source = "./modules/elasticache"

  availability_zones            = var.azs
  engine_version                = var.redis_engine_version
  family                        = var.redis_family
  instance_type                 = var.redis_instance_type
  associated_security_group_ids = tolist([module.sg.redis_security_group_id, ])
  subnets                       = module.vpc.private_subnets
  vpc_id                        = module.vpc.vpc_id

  namespace = local.name
  name      = "message-pub/sub"
  stage     = local.common_tags.Environment
  tags      = local.common_tags
}

###################################
# s3
###################################

# vue bucket
module "vue_s3" {
  source = "./modules/s3"

  bucket_prefix = local.name
  tags          = local.common_tags
}

resource "aws_s3_bucket_policy" "vue" {
  bucket = module.vue_s3.s3_bucket_id
  policy = module.vue_s3.vue_bucket_policy.json

  depends_on = [module.vue_s3]
}

###################################
# k8s
###################################
module "eks" {
  source = "./modules/eks"

  cluster_config_values = templatefile("./templates/k8s/cluster.yaml.tmpl", local.cluster_config_vars)
  filename              = "./cluster.yaml"
}
