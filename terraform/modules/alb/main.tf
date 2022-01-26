# https://github.com/terraform-aws-modules/terraform-aws-alb
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "6.6.1"

  name               = var.name
  load_balancer_type = "application"
  vpc_id             = var.vpc_id
  subnets            = var.subnets
  security_groups    = var.security_groups
  internal           = false

  target_groups = var.target_groups

  http_tcp_listeners      = var.http_tcp_listeners
  http_tcp_listener_rules = var.http_tcp_listener_rules
}
