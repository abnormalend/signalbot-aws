#Jokes is the "hello world" of chatbot functions, and mostly serves as a reference to the process to deploy a function

module "jokes" {
# These top values in general won't change from function to function.
  source            = "./modules/chatbot_function"
  function_file_path = "${path.cwd}/functions"   
  router_role_name  = aws_iam_role.message_router.id
  env               = var.env

# What do we name the function?  This is in AWS, not in the chatbot messages.  This is also the name of the function (minus .py)
  function_name     = "jokes"                               
  
# Who can call the function?  This is a work in progress
  valid_users       = "all"

# What /command starts the message that invokes this function.  In this case /send_joke will trigger this function
  invoke_string     = "send_joke"

# If the function requires additional python modules, we need to build a layer.  Lambda has few by default (boto3)
  layers            = [aws_lambda_layer_version.pyjokes.arn]
}