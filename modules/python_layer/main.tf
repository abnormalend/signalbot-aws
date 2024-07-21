locals {
  temp_dir = "${path.module}/temp/${var.layer_name}"
}

resource "local_file" "build_dir" {
  filename = "${local.temp_dir}/python/requirements.txt"
  content  = var.requirements
}


data "pypi_requirements_file" "mah_requirements" {
  requirements_file = "${local.temp_dir}/python/requirements.txt"
  output_dir = "${local.temp_dir}/python/"
}
# resource "null_resource" "install_libraries" {
#   provisioner "local-exec" {
#     # when        = create
#     working_dir = "${local.temp_dir}/python"
#     command     = "pip install -r requirements.txt -t ."
#   }

#   # triggers = {
#   #   run_on_requirements_change =var.requirements
#   # }
#   depends_on = [local_file.build_dir]
# }

data "archive_file" "this" {
  type        = "zip"
  source_dir  = local.temp_dir
  output_path = "${var.layer_name}.zip"
  depends_on  = [data.pypi_requirements_file.mah_requirements]
}

resource "aws_lambda_layer_version" "this" {
  layer_name          = var.layer_name
  filename            = data.archive_file.this.output_path
  source_code_hash    = sha256(var.requirements)
  compatible_runtimes = var.runtimes
}

output arn {
    value = aws_lambda_layer_version.this.arn
}