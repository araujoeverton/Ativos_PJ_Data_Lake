# modules/s3/outputs.tf
output "bronze_bucket_name" {
  description = "Nome do bucket Bronze"
  value       = aws_s3_bucket.bronze.bucket
}

output "silver_bucket_name" {
  description = "Nome do bucket Silver"
  value       = aws_s3_bucket.silver.bucket
}

output "gold_bucket_name" {
  description = "Nome do bucket Gold"
  value       = aws_s3_bucket.gold.bucket
}

output "scripts_bucket_name" {
  description = "Nome do bucket de scripts"
  value       = aws_s3_bucket.scripts.bucket
}

output "bronze_bucket_arn" {
  description = "ARN do bucket Bronze"
  value       = aws_s3_bucket.bronze.arn
}

output "silver_bucket_arn" {
  description = "ARN do bucket Silver"
  value       = aws_s3_bucket.silver.arn
}

output "gold_bucket_arn" {
  description = "ARN do bucket Gold"
  value       = aws_s3_bucket.gold.arn
}

output "scripts_bucket_arn" {
  description = "ARN do bucket de scripts"
  value       = aws_s3_bucket.scripts.arn
}

output "kms_key_arn" {
  description = "ARN da KMS key"
  value       = aws_kms_key.datalake_key.arn
}