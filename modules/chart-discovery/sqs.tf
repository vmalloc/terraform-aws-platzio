resource "aws_sqs_queue" "this" {
  name                      = "${var.name_prefix}-chart-discovery"
  message_retention_seconds = 1209600
  receive_wait_time_seconds = 20
}

data "aws_iam_policy_document" "queue_policy" {
  statement {
    actions = ["sqs:SendMessage"]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
    resources = [aws_sqs_queue.this.arn]
  }
}

resource "aws_sqs_queue_policy" "this" {
  queue_url = aws_sqs_queue.this.url
  policy    = data.aws_iam_policy_document.queue_policy.json
}
