data "archive_file" "message_router" {
  type        = "zip"
  source_file = "message_router.py"
  output_path = "message_router.zip"
}

resource "aws_lambda_function" "message_router" {
  function_name    = "message_router_${var.env}"
  role             = aws_iam_role.message_router.arn
  filename         = data.archive_file.message_router.output_path
  source_code_hash = data.archive_file.message_router.output_base64sha256
  runtime          = "python3.12"
  handler          = "message_router.lambda_handler"

}

resource "aws_iam_role" "message_router" {
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
  role       = aws_iam_role.message_router.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "message_router_permissions" {
  statement {
    sid = "inboundqueue"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes"
    ]
    resources = [
      aws_sqs_queue.inbound.arn
    ]
  }

  statement {
    sid = "outboundqueue"
    actions = [
      "sqs:SendMessage"
    ]
    resources = [
      aws_sqs_queue.outbound.arn
    ]
  }
}

resource "aws_iam_policy" "message_router_permissions" {
  name   = "message_router_permissions_${var.env}"
  policy = data.aws_iam_policy_document.message_router_permissions.json
}

resource "aws_iam_role_policy_attachment" "message_router_permissions" {
  role       = aws_iam_role.message_router.id
  policy_arn = aws_iam_policy.message_router_permissions.arn
}

resource "aws_lambda_event_source_mapping" "inbound" {
  function_name    = aws_lambda_function.message_router.function_name
  event_source_arn = aws_sqs_queue.inbound.arn
}