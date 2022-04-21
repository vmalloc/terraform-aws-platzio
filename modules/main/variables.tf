variable "k8s_cluster_name" {
  description = "Name of EKS cluster, used for getting credentials"
  type        = string
}

variable "k8s_namespace" {
  description = "Kubernetes namespace name, also used as prefix for AWS resources"
  type        = string
  default     = "platz"
}

variable "helm_release_name" {
  description = "The name of the Helm release"
  default     = "platz"
}

variable "chart_version" {
  description = "Helm chart version to deploy"
  type        = string
  default     = "0.3.0-beta.5"
}

variable "domain" {
  description = "Domain to use for ingress"
  type        = string
}

variable "tls_secret_name" {
  description = "Secret name to use for ingress TLS"
  type        = string
}

variable "oidc_ssm_params" {
  description = "SSM parameter names for configuring OIDC authentication"
  type = object({
    server_url    = string
    client_id     = string
    client_secret = string
  })
}

variable "api_enable_v1" {
  description = "Enable /api/v1 backend paths"
  type        = bool
  default     = false
}

variable "use_chart_db" {
  description = "Use the postgresql sub-chart for deploying a database"
  type        = bool
  default     = true
}

variable "db_url_override" {
  description = "Provide an override URL for the database (set use_chart_db=false if using this variable)"
  type        = string
  default     = ""
}

variable "chart_discovery" {
  description = "SQS queue and IAM role for discovering charts in ECR. This variable should use the outputs of the chart-discovery terraform module"
  default     = null
  type = object({
    iam_role_arn = string
    queue_name   = string
    queue_region = string
  })
}

variable "k8s_agents" {
  description = "A list of IAM roles, once for each k8s-agent to run. Each list item of this variable should use the outputs of the k8s-agent-role terraform module"
  type = list(object({
    name         = string
    iam_role_arn = string
  }))
}
