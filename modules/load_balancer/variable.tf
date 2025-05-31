variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "The security groups for the VPC"
  type        = list(string)
}

variable "subnets" {
  description = "The subnets for the load balancer"
  type        = list(string)
}

variable "load_balancer_name" {
  description = "The name of the load balancer"
  type        = string
}



