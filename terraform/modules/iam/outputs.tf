# modules/iam/outputs.tf
output "glue_role_arn" {
  description = "ARN da IAM role para o Glue"
  value       = aws_iam_role.glue_role.arn
}

output "step_functions_role_arn" {
  description = "ARN da IAM role para o Step Functions"
  value       = aws_iam_role.step_functions_role.arn
}