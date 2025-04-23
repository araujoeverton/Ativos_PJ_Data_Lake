# modules/glue/outputs.tf
output "bronze_database_name" {
  description = "Nome do database Bronze"
  value       = aws_glue_catalog_database.bronze_db.name
}

output "silver_database_name" {
  description = "Nome do database Silver"
  value       = aws_glue_catalog_database.silver_db.name
}

output "gold_database_name" {
  description = "Nome do database Gold"
  value       = aws_glue_catalog_database.gold_db.name
}

output "bronze_database_arn" {
  description = "ARN do database Bronze"
  value       = aws_glue_catalog_database.bronze_db.arn
}

output "silver_database_arn" {
  description = "ARN do database Silver"
  value       = aws_glue_catalog_database.silver_db.arn
}

output "gold_database_arn" {
  description = "ARN do database Gold"
  value       = aws_glue_catalog_database.gold_db.arn
}

output "bronze_crawler_name" {
  description = "Nome do crawler Bronze"
  value       = aws_glue_crawler.bronze_crawler.name
}

output "silver_crawler_name" {
  description = "Nome do crawler Silver"
  value       = aws_glue_crawler.silver_crawler.name
}

output "gold_crawler_name" {
  description = "Nome do crawler Gold"
  value       = aws_glue_crawler.gold_crawler.name
}

output "bronze_crawler_arn" {
  description = "ARN do crawler Bronze"
  value       = aws_glue_crawler.bronze_crawler.arn
}

output "silver_crawler_arn" {
  description = "ARN do crawler Silver"
  value       = aws_glue_crawler.silver_crawler.arn
}

output "gold_crawler_arn" {
  description = "ARN do crawler Gold"
  value       = aws_glue_crawler.gold_crawler.arn
}

output "bronze_to_silver_job_name" {
  description = "Nome do job Bronze to Silver"
  value       = aws_glue_job.bronze_to_silver.name
}

output "silver_to_gold_job_name" {
  description = "Nome do job Silver to Gold"
  value       = aws_glue_job.silver_to_gold.name
}

output "bronze_to_silver_job_arn" {
  description = "ARN do job Bronze to Silver"
  value       = aws_glue_job.bronze_to_silver.arn
}

output "silver_to_gold_job_arn" {
  description = "ARN do job Silver to Gold"
  value       = aws_glue_job.silver_to_gold.arn
}

output "trigger_bronze_to_silver_job_name" {
  description = "Nome do trigger do job Bronze to Silver"
  value       = aws_glue_trigger.trigger_bronze_to_silver_job.name
}

output "trigger_bronze_to_silver_job_arn" {
  description = "ARN do trigger do job Bronze to Silver"
  value       = aws_glue_trigger.trigger_bronze_to_silver_job.arn
}

output "trigger_silver_crawler_name" {
  description = "Nome do trigger do crawler Silver"
  value       = aws_glue_trigger.trigger_silver_crawler.name
}

output "trigger_silver_crawler_arn" {
  description = "ARN do trigger do crawler Silver"
  value       = aws_glue_trigger.trigger_silver_crawler.arn
}

output "trigger_silver_to_gold_job_name" {
  description = "Nome do trigger do job Silver to Gold"
  value       = aws_glue_trigger.trigger_silver_to_gold_job.name
}

output "trigger_silver_to_gold_job_arn" {
  description = "ARN do trigger do job Silver to Gold"
  value       = aws_glue_trigger.trigger_silver_to_gold_job.arn
}

output "trigger_gold_crawler_name" {
  description = "Nome do trigger do crawler Gold"
  value       = aws_glue_trigger.trigger_gold_crawler.name
}

output "trigger_gold_crawler_arn" {
  description = "ARN do trigger do crawler Gold"
  value       = aws_glue_trigger.trigger_gold_crawler.arn
}

output "script_location_bronze_to_silver" {
  description = "Localização do script Bronze to Silver"
  value       = "s3://${var.buckets.scripts}/${aws_s3_object.bronze_to_silver_script.key}"
}

output "script_location_silver_to_gold" {
  description = "Localização do script Silver to Gold"
  value       = "s3://${var.buckets.scripts}/${aws_s3_object.silver_to_gold_script.key}"
}

output "all_resources" {
  description = "Lista de todos os recursos criados pelo módulo Glue"
  value = {
    databases = {
      bronze = aws_glue_catalog_database.bronze_db.name,
      silver = aws_glue_catalog_database.silver_db.name,
      gold   = aws_glue_catalog_database.gold_db.name
    },
    crawlers = {
      bronze = aws_glue_crawler.bronze_crawler.name,
      silver = aws_glue_crawler.silver_crawler.name,
      gold   = aws_glue_crawler.gold_crawler.name
    },
    jobs = {
      bronze_to_silver = aws_glue_job.bronze_to_silver.name,
      silver_to_gold   = aws_glue_job.silver_to_gold.name
    },
    triggers = {
      bronze_crawler = aws_glue_trigger.trigger_bronze_crawler.name,
      bronze_to_silver_job = aws_glue_trigger.trigger_bronze_to_silver_job.name,
      silver_crawler = aws_glue_trigger.trigger_silver_crawler.name,
      silver_to_gold_job = aws_glue_trigger.trigger_silver_to_gold_job.name,
      gold_crawler = aws_glue_trigger.trigger_gold_crawler.name
    }
  }
}