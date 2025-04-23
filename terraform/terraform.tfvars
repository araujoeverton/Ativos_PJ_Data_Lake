###############################################################
# terraform.tfvars (Exemplo de Valores das Variáveis)
###############################################################

aws_region = "us-east-1"
project    = "datalake"
environment = "homolog"

data_lake_bucket_names = {
  bronze = "bronze"
  silver = "silver"
  gold   = "gold"
}

glue_database_names = {
  bronze = "bronze_db"
  silver = "silver_db"
  gold   = "gold_db"
}

glue_crawler_names = {
  bronze = "bronze_crawler"
  silver = "silver_crawler"
  gold   = "gold_crawler"
}

glue_job_names = {
  bronze_to_silver = "bronze_to_silver_job"
  silver_to_gold   = "silver_to_gold_job"
}

glue_scripts_bucket = "glue-scripts"

# Definições de ciclo de vida
bronze_lifecycle_ia_days = 30
bronze_lifecycle_glacier_days = 90
silver_lifecycle_ia_days = 90
gold_lifecycle_ia_days = 90

# Agendamento do Step Functions
step_functions_schedule = "cron(0 1 * * ? *)"