module "jokes_layer" {
  source            = "./modules/python_layer"
  layer_name        = "pyjokes"
  requirements_path = "${path.root}/functions/jokes/requirements.txt"
}