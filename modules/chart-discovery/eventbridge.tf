resource "aws_cloudwatch_event_rule" "this" {
  name     = "${var.name_prefix}-chart-discovery"
  role_arn = aws_iam_role.eventbridge.arn

  event_pattern = <<EOF
{
    "detail-type": [
        "ECR Image Action"
    ],
    "source": [
        "aws.ecr"
    ],
    "detail": {
        "action-type": [
            "PUSH",
            "DELETE"
        ],
        "result": [
            "SUCCESS"
        ]
    }
}
EOF
}

resource "aws_cloudwatch_event_target" "this" {
  rule = aws_cloudwatch_event_rule.this.name
  arn  = aws_sqs_queue.this.arn
}

resource "aws_iam_role" "eventbridge" {
  name               = "${var.name_prefix}-chart-discovery-eventbridge"
  assume_role_policy = data.aws_iam_policy_document.eventbridge_assume_role.json
}

data "aws_iam_policy_document" "eventbridge_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}
