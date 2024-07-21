module "jokes_layer" {
  source     = "./modules/python_layer"
  layer_name = "pyjokes"
  requirements = "pyjokes"
}

module "jokes" {
  source            = "./modules/chatbot_function"
  function_name     = "jokes"
  function_filename = "functions/jokes.py"
  valid_users       = "all"
  invoke_string     = "joke"
  router_arn        = aws_lambda_function.message_router.arn
  env               = var.env
  layers            = [module.jokes_layer.arn]
}