# This contains the resources for making a user that the container can connect as 
#     and communicate with the queues

resource "aws_iam_user" "container" {
  name = "signalbot-container-${var.env}"
}

resource "aws_iam_access_key" "container" {
  user = aws_iam_user.container.name
}

data "aws_iam_policy_document" "container" {
  statement {
    sid = "request"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes"
    ]
    resources = [
      aws_sqs_queue.outbound.arn
    ]
  }
  statement {
    sid = "response"
    actions = [
      "sqs:SendMessage"
    ]
    resources = [
      aws_sqs_queue.inbound.arn
    ]
  }
}

resource "aws_iam_policy" "container" {
  name   = "container-access-${var.env}"
  policy = data.aws_iam_policy_document.container.json
}

resource "aws_iam_user_policy_attachment" "container" {
  policy_arn = aws_iam_policy.container.arn
  user       = aws_iam_user.container.name
}