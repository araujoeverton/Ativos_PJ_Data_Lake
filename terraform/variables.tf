###############################################################
# variables.tf (Arquivo de Variáveis Principal)
###############################################################

variable "aws_region" {
  description = "Região AWS onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Nome do projeto"
  type        = string
  default     = "datalake"
}

variable "environment" {
  description = "Ambiente (dev, stg, prd)"
  type        = string
  default     = "dev"
}

variable "data_lake_bucket_names" {
  description = "Nome dos buckets (bronze, silver, gold)"
  type        = map(string)
  default = {
    bronze = "bronze"
    silver = "silver"
    gold   = "gold"
  }
}

variable "glue_database_names" {
  description = "Nome dos bancos de dados Glue (bronze, silver, gold)"
  type        = map(string)
  default = {
    bronze = "bronze_db"
    silver = "silver_db"
    gold   = "gold_db"
  }
}

variable "glue_crawler_names" {
  description = "Nome dos crawlers Glue (bronze, silver, gold)"
  type        = map(string)
  default = {
    bronze = "bronze_crawler"
    silver = "silver_crawler"
    gold   = "gold_crawler"
  }
}

variable "glue_job_names" {
  description = "Nome dos jobs Glue"
  type        = map(string)
  default = {
    bronze_to_silver = "bronze_to_silver_job"
    silver_to_gold   = "silver_to_gold_job"
  }
}

variable "glue_scripts_bucket" {
  description = "Nome do bucket para armazenar scripts Glue"
  type        = string
  default     = "glue-scripts"
}

variable "data_lake_admin_arn" {
  description = "ARN do IAM Role/User que será administrador do Lake Formation"
  type        = string
  default     = null
}

variable "bronze_lifecycle_ia_days" {
  description = "Dias para transição para IA no bucket Bronze"
  type        = number
  default     = 30
}

variable "bronze_lifecycle_glacier_days" {
  description = "Dias para transição para Glacier no bucket Bronze"
  type        = number
  default     = 90
}

variable "silver_lifecycle_ia_days" {
  description = "Dias para transição para IA no bucket Silver"
  type        = number
  default     = 90
}

variable "gold_lifecycle_ia_days" {
  description = "Dias para transição para IA no bucket Gold"
  type        = number
  default     = 90
}

variable "step_functions_schedule" {
  description = "Expressão cron para agendamento do Step Functions"
  type        = string
  default     = "cron(0 1 * * ? *)" # 1 AM diariamente
}