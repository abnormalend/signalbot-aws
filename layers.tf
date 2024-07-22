# Define layers with additional libraries here, for use by any functions that need them.

resource "aws_lambda_layer_version" "pyjokes" {
  layer_name          = "pyjokes"
  filename            = "./layers/pyjokes.zip"
  source_code_hash    = filebase64sha256("./layers/pyjokes.zip")
  compatible_runtimes = ["python3.12"]
}