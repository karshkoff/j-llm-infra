variable "aws_account_id" {
  description = "The AWS account ID"
  type        = string
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "private_subnet_ids" {
  description = "A list of private subnet IDs"
  type        = list(string)
}

variable "alb_load_balancer_role_name" {
  description = "The name of the ALB Load Balancer Controller"
  type        = string
  default     = "aws-load-balancer-controller"
}

variable "tags" {
  description = "A map of tags to assign to all resources"
  type        = map(string)
  default     = {}
}