variable "k8s_namespace" {
  description = "Kubernetes namespace name where Platz is installed, possibly in another account. The namespace has to match the one used when installing Platz so that the chart-discovery worker can perform AssumeRoleWithWebIdentity to the role created in this module."
  type        = string
  default     = "platz"
}

variable "helm_release_name" {
  description = "The name of the Helm release for installing Platz. Same considerations as the k8s_namespace variable."
  default     = "platz"
}

variable "irsa_issuer_url" {
  description = "IRSA issuer URL of the EKS cluster"
  type        = string
}

variable "irsa_thumbprint" {
  description = "EKS cluster OIDC thumbprint"
  type        = string
}
