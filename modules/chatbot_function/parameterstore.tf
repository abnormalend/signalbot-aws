# We want to record the details of this function in parameter store so that the router lambda can find us
resource "aws_ssm_parameter" "this" {
  name = "/signalbot/function/${var.function_name}"
  type = "String"
  value = <<EOT
  {
    "function_name": "${var.function_name}",
    "arn": "${aws_lambda_function.this.arn}",
    "invoke_arn": "${aws_lambda_function.this.invoke_arn}",
    "invoke_string": "${var.invoke_string}"
  }
  EOT
}