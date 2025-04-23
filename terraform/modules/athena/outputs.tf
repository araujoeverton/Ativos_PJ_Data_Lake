# modules/athena/outputs.tf
output "athena_workgroup_name" {
  description = "Nome do workgroup do Athena"
  value       = aws_athena_workgroup.datalake_workgroup.name
}

output "athena_results_bucket" {
  description = "Nome do bucket de resultados do Athena"
  value       = aws_s3_bucket.athena_results.bucket
}

output "bronze_tables_query_id" {
  description = "ID da consulta para listar tabelas Bronze"
  value       = aws_athena_named_query.bronze_tables.id
}

output "silver_tables_query_id" {
  description = "ID da consulta para listar tabelas Silver"
  value       = aws_athena_named_query.silver_tables.id
}

output "gold_tables_query_id" {
  description = "ID da consulta para listar tabelas Gold"
  value       = aws_athena_named_query.gold_tables.id
}