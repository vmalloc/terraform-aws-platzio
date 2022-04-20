resource "aws_iam_role" "task_runner" {
  name               = "${var.k8s_namespace}-task-runner"
  assume_role_policy = data.aws_iam_policy_document.task_runner_assume_role.json
}

data "aws_iam_policy_document" "task_runner_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${var.irsa_oidc_provider}:sub"
      values   = ["system:serviceaccount:${var.k8s_namespace}:${var.helm_release_name}-task-runner"]
    }

    principals {
      type        = "Federated"
      identifiers = [var.irsa_oidc_arn]
    }
  }
}

resource "aws_iam_policy" "task_runner" {
  name   = "${var.k8s_namespace}-task-runner"
  policy = data.aws_iam_policy_document.task_runner.json
}

data "aws_iam_policy_document" "task_runner" {
  statement {
    actions = [
      "ec2:DescribeRegions",
      "eks:ListClusters",
      "eks:DescribeCluster",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "task_runner" {
  role       = aws_iam_role.task_runner.name
  policy_arn = aws_iam_policy.task_runner.arn
}

resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role       = aws_iam_role.task_runner.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
