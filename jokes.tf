module "jokes_layer" {
  source     = "./modules/python_layer"
  layer_name = "pyjokes"
  requirements = "pyjokes >= 0.6.0"
}

module "jokes" {
  source            = "./modules/chatbot_function"
  function_name     = "jokes"
  function_filename = "${path.cwd}/functions/jokes.py"
  valid_users       = "all"
  invoke_string     = "send_joke"
  router_role_name  = aws_iam_role.message_router.id
  env               = var.env
  layers            = [module.jokes_layer.arn]
}