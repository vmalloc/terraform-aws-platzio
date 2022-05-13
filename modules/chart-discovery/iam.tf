resource "aws_iam_role" "this" {
  name               = "${var.k8s_namespace}-chart-discovery"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${var.irsa_oidc_provider}:sub"
      values   = ["system:serviceaccount:${var.k8s_namespace}:${var.helm_release_name}-chart-discovery"]
    }

    principals {
      type        = "Federated"
      identifiers = [var.irsa_oidc_arn]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_policy" "sqs" {
  name   = "${var.k8s_namespace}-chart-discovery-queue"
  policy = data.aws_iam_policy_document.role_queue_permissions.json
}

data "aws_iam_policy_document" "role_queue_permissions" {
  statement {
    actions = [
      "sqs:DeleteMessage",
      "sqs:GetQueueUrl",
      "sqs:GetQueueAttributes",
      "sqs:ReceiveMessage",
    ]
    resources = [aws_sqs_queue.this.arn]
  }

  statement {
    actions = [
      "sqs:ListQueues",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "sqs" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.sqs.arn
}
