resource "aws_iam_openid_connect_provider" "this" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [var.irsa_thumbprint]
  url             = var.irsa_issuer_url
}

locals {
  irsa_oidc_provider = replace(aws_iam_openid_connect_provider.this.url, "https://", "")
  irsa_oidc_arn      = aws_iam_openid_connect_provider.this.arn
}
