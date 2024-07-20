variable "env" {
  type        = string
  description = "What environment we are deploying in"
  default     = "dev"
}

variable "aws_region" {
  type        = string
  description = "What AWS Region to use"
  default     = "us-east-2"
}