variable "name_prefix" {
  description = "Prefix to use for global resource names such as IAM roles"
  type        = string
  default     = "platz"
}

variable "k8s_namespace" {
  description = "Kubernetes namespace name where Platz is installed, possibly in another account. The namespace has to match the one used when installing Platz so that the chart-discovery worker can perform AssumeRoleWithWebIdentity to the role created in this module."
  type        = string
  default     = "platz"
}

variable "helm_release_name" {
  description = "The name of the Helm release for installing Platz. Same considerations as the k8s_namespace variable."
  default     = "platz"
}

variable "k8s_agent_name" {
  description = "Name of k8s-agent, has to be unique among all other k8s-agent names"
  type        = string
}

variable "irsa_oidc_provider" {
  description = "IRSA OIDC provider address, to be used in assume role documents"
  type        = string
}

variable "irsa_oidc_arn" {
  description = "IRSA OIDC provider ARN"
  type        = string
}
