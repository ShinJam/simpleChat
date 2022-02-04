variable "region" {
  type        = string
  description = "AWS region"
}

variable "environment" {
  type = string
}

#variable "account" {
#  type = string
#}

# vpc
variable "cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overriden"
  default     = "0.0.0.0/0"
}

variable "azs" {
  description = "A list of availability zones in the region"
  type        = list(string)
  default     = []
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "database_subnets" {
  type = list(string)
}

# EC2
variable "ami_id" {
  type = string
}
variable "jenkins_instance_type" {
  type = string
}
variable "server_instance_type" {
  type = string
}

# RDS
variable "engine_version" {
  type = string
}
variable "instance_class" {
  type = string
}
variable "apply_immediately" {
  type = bool
}
variable "database_name" {
  type = string
}
variable "username" {
  type = string
}

variable "password" {
  type = string
}
variable "deletion_protection" {
  type = bool
}
