output "iam_role_arn" {
  description = "IAM role ARN to use with chart-discovery worker"
  value       = aws_iam_role.this.arn
}

output "queue_name" {
  description = "Name of SQS queue receiving ECR notifications"
  value       = aws_sqs_queue.this.name
}

output "queue_region" {
  description = "AWS region of the SQS queue"
  value       = data.aws_region.current.name
}
