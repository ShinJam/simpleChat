variable "name" {
  description = "Name to be used on all the resources as identifier"
}
variable "engine_version" {
  description = "The engine version to use"
  type        = string
}
variable "instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
}
variable "apply_immediately" {
  description = "Specifies whether any database modifications are applied immediately, or during the next maintenance window"
  type        = bool
}
variable "tags" {
  description = "A mapping of tags to assign to security group"
  type        = map(string)
}
variable "database_name" {
  description = "The DB name to create. If omitted, no database is created initially"
  type        = string
}
variable "username" {
  description = "Username for the master DB user"
  type        = string
}

variable "password" {
  description = "Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file"
  type        = string
}
variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate"
  type        = list(string)
}
variable "subnet_ids" {
  description = "A list of VPC subnet IDs"
  type        = list(string)
}
variable "deletion_protection" {
  description = "The database can't be deleted when this value is set to true."
  type        = bool
}
variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted. If true is specified, no DBSnapshot is created. If false is specified, a DB snapshot is created before the DB instance is deleted, using the value from final_snapshot_identifier"
  type        = bool
  default     = true
}
