variable "availability_zones" {
  type        = list(string)
  description = "Availability zone IDs"
}

variable "vpc_id" {
  description = "ID of the VPC where to create security group"
  type        = string
}

variable "allowed_security_group_ids" {
  type        = list(string)
  default     = []
  description = <<-EOT
    A list of IDs of Security Groups to allow access to the security group created by this module.
  EOT
}
variable "subnets" {
  type        = list(string)
  description = "Subnet IDs"
}
variable "cluster_size" {
  type        = number
  default     = 1
  description = "Number of nodes in cluster. *Ignored when `cluster_mode_enabled` == `true`*"
}
variable "instance_type" {
  type        = string
  description = "Elastic cache instance type"
}
variable "engine_version" {
  type        = string
  description = "Redis engine version"
}
variable "family" {
  type        = string
  description = "Redis family"
}
variable "at_rest_encryption_enabled" {
  type        = bool
  default     = false
  description = "Enable encryption at rest"
}
variable "transit_encryption_enabled" {
  type        = bool
  default     = false
  description = <<-EOT
    Set `true` to enable encryption in transit. Forced `true` if `var.auth_token` is set.
    If this is enabled, use the [following guide](https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/in-transit-encryption.html#connect-tls) to access redis.
    EOT
}
variable "associated_security_group_ids" {
  type        = list(string)
  description = <<-EOT
    A list of IDs of Security Groups to associate the created resource with, in addition to the created security group.
    These security groups will not be modified and, if `create_security_group` is `false`, must provide all the required access.
    EOT
}
variable "tags" {
  description = "A mapping of tags to assign to security group"
  type        = map(string)
}
variable "namespace" {
  type        = string
  description = "ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique"
}
variable "name" {
  type        = string
  description = <<-EOT
    ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.
    This is the only ID element not also included as a `tag`.
    The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input.
    EOT
}
variable "stage" {
  type        = string
  description = "ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release'"
}
