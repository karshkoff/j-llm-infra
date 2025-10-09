# Issue with AWS signed cert: PENDING_VALIDATION
# Using self-signed cert for now

variable "self_signed_cert_arn" {
  description = "Self-signed certificate for the ALB"
  type        = string
  default     = "arn:aws:acm:us-east-1:598342749197:certificate/bc2addcf-0583-451b-8018-2e4bf57e730b"
}

variable "tags" {
  description = "A map of tags to assign to all resources"
  type        = map(string)
  default     = {}
}