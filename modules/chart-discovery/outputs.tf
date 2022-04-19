output "iam_role_arn" {
  description = "IAM role ARN to use with chart-discovery worker"
  value       = aws_iam_role.this.arn
}

output "sqs_queue_name" {
  description = "Name of SQS queue receiving ECR notifications"
  value       = aws_sqs_queue.this.name
}

output "sqs_queue_region" {
  description = "AWS region of the SQS queue"
  value       = data.aws_region.current.name
}
