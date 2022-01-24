variable "ami" {
  description = "ID of AMI to use for the instance"
  type        = string
}

variable "name" {
  type = string
}
variable "instance_type" {
  description = "The type of instance to start"
  type        = string
}

variable "key_name" {
  description = "Key name of the Key Pair to use for the instance; which can be managed using the `aws_key_pair` resource"
  type        = string
}

variable "subnet_id" {
  description = "The VPC Subnet ID to launch in"
  type        = string
}
variable "sg_ids" {
  description = "A list of security group IDs to associate with"
  type        = list(string)
}

variable "tags" {
  type = map(string)
}

