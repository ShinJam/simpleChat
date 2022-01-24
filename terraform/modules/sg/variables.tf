variable "vpc_id" {
  description = "ID of the VPC where to create security group"
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to security group"
  type        = map(string)
}
