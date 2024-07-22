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