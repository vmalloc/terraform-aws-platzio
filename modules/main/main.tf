resource "kubernetes_namespace" "this" {
  metadata {
    name = var.k8s_namespace
  }
}

resource "helm_release" "this" {
  depends_on = [
    kubernetes_namespace.this,
    kubernetes_secret.oidc_config,
  ]

  name       = var.helm_release_name
  namespace  = var.k8s_namespace
  repository = "https://platzio.github.io/helm-charts"
  chart      = "platzio"
  version    = var.chart_version

  values = [templatefile("${path.module}/values.yaml", {
    domain          = var.domain
    tls_secret_name = var.tls_secret_name
    api_enable_v1   = var.api_enable_v1
    chart_discovery = var.chart_discovery
    k8s_agents      = var.k8s_agents
    use_chart_db    = var.use_chart_db
    db_url_override = var.db_url_override
  })]
}
