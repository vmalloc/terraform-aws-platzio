resource "aws_iam_role" "this" {
  name               = "${var.k8s_namespace}-k8s-agent-${var.k8s_agent_name}"
  assume_role_policy = data.aws_iam_policy_document.this_assume_role.json
}

data "aws_iam_policy_document" "this_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${var.irsa_oidc_provider}:sub"
      values   = ["system:serviceaccount:${var.k8s_namespace}:${var.helm_release_name}-k8s-agent-${var.k8s_agent_name}"]
    }

    principals {
      type        = "Federated"
      identifiers = [var.irsa_oidc_arn]
    }
  }
}

resource "aws_iam_policy" "this" {
  name   = "${var.k8s_namespace}-k8s-agent"
  policy = data.aws_iam_policy_document.this.json
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = [
      "ec2:DescribeRegions",
      "eks:ListClusters",
      "eks:DescribeCluster",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
