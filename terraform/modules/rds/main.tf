# source: https://github.com/terraform-aws-modules/terraform-aws-rds
# example: https://github.com/terraform-aws-modules/terraform-aws-rds/blob/master/examples/complete-postgres/main.tf
#
module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 3.0"

  identifier = var.name

  engine            = "postgres"
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = 5
  max_allocated_storage = 10
  storage_encrypted = false
  apply_immediately = var.apply_immediately

  #kms_key_id        = "arm:aws:kms:<region>:<account id>:key/<kms key id>"
  name     = var.database_name
  username = var.username
  password = var.password
  port     = "5432"

  vpc_security_group_ids = var.vpc_security_group_ids

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # disable backups to create DB faster
  backup_retention_period         = 0
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  # DB subnet group
  subnet_ids = var.subnet_ids

  # DB parameter group
  family = "postgres14"

  # DB option group
  major_engine_version = "14"

  # Database Deletion Protection
  deletion_protection = var.deletion_protection

  skip_final_snapshot = var.skip_final_snapshot

  tags = var.tags
}
