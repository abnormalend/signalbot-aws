variable "function_name" {
  type        = string
  description = "What is the name of the lambda function?"
}

variable "function_filename" {
  type        = string
  description = "What is the name of the lambda function on the filesystem?"
}

variable "env" {
  type = string
}

variable "runtime" {
  type    = string
  default = "python3.12"
}

variable "handler" {
  type        = string
  default     = "lambda_handler"
  description = "This is just the second half, we work out the first half from function_filename"
}

variable "invoke_string" {
  type = string
}

variable "valid_users" {
  type = string
}

variable "extra_permissions" {
  type        = set(string)
  description = "Extra Polcy ARNS to attach to the role"
  default     = []
}

variable "router_arn" {
  type        = string
  description = "The function to grant invoke permissions to"
}
