variable "backend_bucket" {
  description = "The name of the tf-backend S3 bucket"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to all resources"
  type        = map(string)
  default     = {}
}
