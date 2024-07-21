variable "requirements" {
  type        = string
  description = "What to install?"
}

variable "layer_name" {
  type = string
}

variable "runtimes" {
  type    = set(string)
  default = ["python3.12"]
}