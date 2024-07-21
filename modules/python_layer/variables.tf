variable "requirements_path" {
  type        = string
  description = "Where to find the requirements folder"
}

variable "layer_name" {
  type = string
}

variable "runtimes" {
  type    = set(string)
  default = ["python3.12"]
}