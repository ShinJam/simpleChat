locals {
  # https://www.terraform.io/docs/language/values/locals.html

  name = "kuve"
  # Name, TerraformPath, VPC, Creator 추가 필요
  common_tags = {
    TerraformManaged = true
    Environment = var.environment
    Project = "kuve"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
  }
  ec2 = {
    key_name = "kuve-ec2"
  }

  cluster_config_vars = {
    cluster_name     = var.eks_cluster_name
    region           = var.region
    public_key_name  = local.ec2.key_name
    instance_type    = var.eks_instance_type
    min_size         = var.eks_node_min_size
    max_size         = var.eks_node_max_size
    desired_capacity = var.eks_desired_node_capacity

    subnet_private = {
      private0 = element(module.vpc.private_subnets, 0),
      private1 = element(module.vpc.private_subnets, 1),
    }

    subnet_public = {
      public0 = element(module.vpc.public_subnets, 0),
      public1 = element(module.vpc.public_subnets, 1),
    }
  }
    alb = {
      http_tcp_listeners = [
        {
          port        = 80
          protocol    = "HTTP"
          action_type = "fixed-response"
          fixed_response = {
            content_type = "text/plain"
            message_body = "Not found"
            status_code  = "403"
          }
        },
        {
          port        = 8080
          protocol    = "HTTP"
          action_type = "fixed-response"
          fixed_response = {
            content_type = "text/plain"
            message_body = "Not found"
            status_code  = "403"
          }
        }
      ]
      http_tcp_listener_rules = [
#        {
#          http_tcp_listener_index = 0
#          actions = [{
#            type               = "forward"
#            target_group_index = 0
#          }]
#          conditions = [{
#            path_patterns = ["/*"]
#          }]
#        },
        {
          http_tcp_listener_index = 1
          actions = [{
            type               = "forward"
            target_group_index = 0
          }]
          conditions = [{
            path_patterns = ["/*"]
          }]
        }
      ]
      target_groups = [
#        {
#          name_prefix      = "tg-"
#          backend_protocol = "HTTP"
#          backend_port     = 80 # aws_lb_target_group
#          target_type      = "instance"
#
#          health_check = {
#            path = "/"
#          }
#
#          targets = {
#            jenkins = {
#              target_id = module.api-server.id
#              port      = 80 # aws_lb_target_group_attachment
#            }
#          }
#          tags = local.common_tags
#        },
        {
          name_prefix      = "tg-"
          backend_protocol = "HTTP"
          backend_port     = 8080 # aws_lb_target_group
          target_type      = "instance"

          health_check = {
            path = "/login"
          }

          targets = {
            jenkins = {
              target_id = module.jenkins.id
              port      = 8080 # aws_lb_target_group_attachment
            }
          }
          tags = local.common_tags
        },
      ]
    }
}
