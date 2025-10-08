variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "private_subnet_ids" {
  description = "A list of private subnet IDs"
  type        = list(string)
}

variable "tags" {
  description = "A map of tags to assign to all resources"
  type        = map(string)
  default     = {}
}