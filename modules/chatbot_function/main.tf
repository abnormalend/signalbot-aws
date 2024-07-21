data "archive_file" "this" {
  type        = "zip"
  source_file = "${var.function_filename}.py"
  output_path = "${var.function_name}.zip"
}

locals {
  function_name = "signalbot-function-${var.function_name}-${var.env}"
  handler       = "${replace(var.function_filename, ".py", "")}.${var.handler}"
}

resource "aws_lambda_function" "this" {
  function_name    = local.function_name
  role             = aws_iam_role.this.arn
  filename         = data.archive_file.this.output_path
  source_code_hash = data.archive_file.this.output_base64sha256
  runtime          = var.runtime
  handler          = local.handler

  tags = {
    invoke = var.invoke_string
    users  = var.valid_users
  }

  layers = var.layers
}

resource "aws_iam_role" "this" {
  name               = "message_router_lambda_role_${var.env}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.this.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "extras" {
  for_each   = var.extra_permissions
  role       = aws_iam_role.this.id
  policy_arn = each.key
}

data "aws_iam_policy_document" "allow_router" {
  statement {
    sid = local.function_name
    actions = [
      "lambda:InvokeFunction",
      "lambda:InvokeAsync"
    ]
    resources = [
      aws_lambda_function.this.arn
    ]
  }
}

resource "aws_iam_policy" "allow_router" {
  name   = "message_router_${local.function_name}"
  policy = data.aws_iam_policy_document.allow_router.json
}

resource "aws_iam_role_policy_attachment" "allow_router" {
  role       = var.router_arn
  policy_arn = aws_iam_policy.allow_router.arn
}