variable "ami" {
  description = "ID of AMI to use for the instance"
  type        = string
}

variable "name" {
  type = string
}

variable "security_groups" {
  type        = list(string)
  description = "A list of Security Group IDs to associate with bastion host."
  default     = []
}

variable "subnets" {
  type        = list(string)
  description = "AWS subnet IDs"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "key_name" {
  description = "Key name of the Key Pair to use for the instance; which can be managed using the `aws_key_pair` resource"
  type        = string
}

variable "tags" {
  type = map(string)
}

