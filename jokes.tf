# module "jokes_layer" {
#   source     = "./modules/python_layer"
#   layer_name = "pyjokes"
#   requirements = "pyjokes >= 0.6.0"
# }

resource "aws_lambda_layer_version" "pyjokes" {
  layer_name          = "pyjokes"
  filename            = "./layers/pyjokes.zip"
  source_code_hash    = filebase64sha256("./layers/pyjokes.zip")
  compatible_runtimes = ["python3.12"]
}


module "jokes" {
  source            = "./modules/chatbot_function"
  function_name     = "jokes"
  function_file_path = "${path.cwd}/functions"
  valid_users       = "all"
  invoke_string     = "send_joke"
  router_role_name  = aws_iam_role.message_router.id
  env               = var.env
  layers            = [aws_lambda_layer_version.pyjokes.arn]
}