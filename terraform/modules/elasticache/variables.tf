variable "availability_zones" {
  type        = list(string)
  description = "Availability zone IDs"
}
variable "zone_id" {
  type        = any
  default     = []
  description = <<-EOT
    Route53 DNS Zone ID as list of string (0 or 1 items). If empty, no custom DNS name will be published.
    If the list contains a single Zone ID, a custom DNS name will be pulished in that zone.
    Can also be a plain string, but that use is DEPRECATED because of Terraform issues.
    EOT
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
variable "security_group_name" {
  type        = list(string)
  description = <<-EOT
    The name to assign to the created security group. Must be unique within the VPC.
    If not provided, will be derived from the `null-label.context` passed in.
    If `create_before_destroy` is true, will be used as a name prefix.
    EOT
}
