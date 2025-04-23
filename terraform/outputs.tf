###############################################################
# outputs.tf (Arquivo de Outputs Principal)
###############################################################

output "bronze_bucket_name" {
  description = "Nome do bucket Bronze"
  value       = module.data_lake_storage.bronze_bucket_name
}

output "silver_bucket_name" {
  description = "Nome do bucket Silver"
  value       = module.data_lake_storage.silver_bucket_name
}

output "gold_bucket_name" {
  description = "Nome do bucket Gold"
  value       = module.data_lake_storage.gold_bucket_name
}

output "scripts_bucket_name" {
  description = "Nome do bucket de scripts"
  value       = module.data_lake_storage.scripts_bucket_name
}

output "glue_databases" {
  description = "Nomes dos databases Glue"
  value = {
    bronze = module.glue.bronze_database_name,
    silver = module.glue.silver_database_name,
    gold   = module.glue.gold_database_name
  }
}

output "glue_crawlers" {
  description = "Nomes dos crawlers Glue"
  value = {
    bronze = module.glue.bronze_crawler_name,
    silver = module.glue.silver_crawler_name,
    gold   = module.glue.gold_crawler_name
  }
}

output "glue_jobs" {
  description = "Nomes dos jobs Glue"
  value = {
    bronze_to_silver = module.glue.bronze_to_silver_job_name,
    silver_to_gold   = module.glue.silver_to_gold_job_name
  }
}

output "step_function_state_machine_arn" {
  description = "ARN do State Machine do Step Functions"
  value       = module.step_functions.state_machine_arn
}