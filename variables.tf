# AWS config

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# Tags

variable "project" {
  description = "Project name"
  type        = string
  default     = "j-llm"
}

variable "repo" {
  description = "Project GitHub repo url"
  type        = string
  default     = "https://github.com/karshkoff/j-llm-infra"
}

