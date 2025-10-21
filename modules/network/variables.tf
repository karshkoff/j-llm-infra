variable "domain_name" {
  description = "The domain name for the application (e.g., example.com)"
  type        = string
  default     = ""
}

variable "region" {
  description = "The AWS region to deploy resources"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to all resources"
  type        = map(string)
  default     = {}
}