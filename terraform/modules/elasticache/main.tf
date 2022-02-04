# https://github.com/cloudposse/terraform-aws-elasticache-redis
module "redis" {
  source = "cloudposse/elasticache-redis/aws"
  version = "0.42.0"

  availability_zones               = var.availability_zones
  vpc_id                           = var.vpc_id
  allowed_security_groups          = var.allowed_security_group_ids
  subnets                          = var.subnets
  cluster_size                     = var.cluster_size
  instance_type                    = var.instance_type
  apply_immediately                = true
  automatic_failover_enabled       = false
  engine_version                   = var.engine_version
  family                           = var.family
  at_rest_encryption_enabled       = var.at_rest_encryption_enabled
  transit_encryption_enabled       = var.transit_encryption_enabled

  # Verify that we can safely change security groups (name changes forces new SG)
  security_group_create_before_destroy = true
  create_security_group = false
  associated_security_group_ids = var.associated_security_group_ids

  security_group_delete_timeout = "5m"

  # https://github.com/cloudposse/terraform-aws-elasticache-redis/issues/16
  namespace = var.namespace
  name = var.name
  stage = var.stage
  tags = var.tags
}
