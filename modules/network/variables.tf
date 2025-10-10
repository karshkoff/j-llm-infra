variable "domain_name" {
  description = "The domain name for the application (e.g., example.com)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to assign to all resources"
  type        = map(string)
  default     = {}
}