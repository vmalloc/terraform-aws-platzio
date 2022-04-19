data "aws_ssm_parameter" "oidc_server_url" {
  name = var.oidc_ssm_params.server_url
}

data "aws_ssm_parameter" "oidc_client_id" {
  name = var.oidc_ssm_params.client_id
}

data "aws_ssm_parameter" "oidc_client_secret" {
  name = var.oidc_ssm_params.client_secret
}

resource "kubernetes_secret" "oidc_config" {
  depends_on = [
    kubernetes_namespace.this,
  ]

  metadata {
    name      = "oidc-config"
    namespace = var.k8s_namespace
  }

  data = {
    serverUrl    = data.aws_ssm_parameter.oidc_server_url.value
    clientId     = data.aws_ssm_parameter.oidc_client_id.value
    clientSecret = data.aws_ssm_parameter.oidc_client_secret.value
  }
}
