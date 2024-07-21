module "jokes_layer" {
  source            = "./modules/python_layer"
  layer_name        = "pyjokes"
#   requirements_path = "functions/jokes/requirements.txt"
  requirements = "pyjokes==0.7.2"
}