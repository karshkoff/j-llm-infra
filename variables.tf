# AWS provider config

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# Tags

variable "tags" {
  description = "A map of tags to assign to all resources"
  type        = map(string)
  default = {
    project = "j-llm"
    repo    = "https://github.com/karshkoff/j-llm-infra"
  }
}
