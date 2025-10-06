# AWS config
# Always pass profile and region via tfvars
# to avoid deploying resources in wrong region or account

variable "profile" {
  description = "AWS CLI profile"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
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

