output "name" {
  description = "k8s-agent name, as passed to this module"
  value       = var.k8s_agent_name
}

output "iam_role_arn" {
  description = "IAM role ARN to use with k8s-agent worker"
  value       = aws_iam_role.this.arn
}
