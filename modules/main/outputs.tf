output "task_runner_iam_role_arn" {
  description = "IAM role ARN assumed by the task-runner worker. This role should be added to the aws-auth configmap of each cluster to allow Platz to install Helm deployments on it."
  value       = aws_iam_role.task_runner.arn
}
