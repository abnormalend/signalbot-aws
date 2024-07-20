resource "aws_sqs_queue" "inbound" {
  name = "signalbot-inbound-${var.env}"
}

resource "aws_sqs_queue" "outbound" {
  name = "signalbot-outbound-${var.env}"
}