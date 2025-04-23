# modules/glue/variables.tf
variable "project" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, stg, prd)"
  type        = string
}

variable "glue_role_arn" {
  description = "ARN da IAM role para o Glue"
  type        = string
}

variable "database_names" {
  description = "Nomes dos bancos de dados Glue"
  type        = map(string)
  default     = {
    bronze = "bronze_db"
    silver = "silver_db"
    gold   = "gold_db"
  }
}

variable "crawler_names" {
  description = "Nomes dos crawlers Glue"
  type        = map(string)
  default     = {
    bronze = "bronze_crawler"
    silver = "silver_crawler"
    gold   = "gold_crawler"
  }
}

variable "job_names" {
  description = "Nomes dos jobs Glue"
  type        = map(string)
  default     = {
    bronze_to_silver = "bronze_to_silver_job"
    silver_to_gold   = "silver_to_gold_job"
  }
}

variable "buckets" {
  description = "Nomes dos buckets S3"
  type        = map(string)
}

variable "scripts" {
  description = "Detalhes dos scripts Glue"
  type        = map(object({
    source_path = string
    target_key  = string
  }))
}

variable "glue_version" {
  description = "Versão do Glue a ser utilizada"
  type        = string
  default     = "3.0"
}

variable "worker_type" {
  description = "Tipo de worker para jobs Glue"
  type        = string
  default     = "G.1X"
}

variable "number_of_workers" {
  description = "Número de workers para jobs Glue"
  type        = number
  default     = 2
}

variable "max_concurrent_runs" {
  description = "Número máximo de execuções concorrentes de jobs"
  type        = number
  default     = 1
}

variable "crawler_schedule" {
  description = "Expressão cron para agendamento dos crawlers"
  type        = string
  default     = "cron(0 */4 * * ? *)" # A cada 4 horas
}

variable "python_version" {
  description = "Versão do Python para scripts Glue"
  type        = string
  default     = "3"
}

variable "crawler_schema_change_policy" {
  description = "Política de mudança de esquema para crawlers"
  type        = object({
    delete_behavior = string
    update_behavior = string
  })
  default     = {
    delete_behavior = "LOG"
    update_behavior = "UPDATE_IN_DATABASE"
  }
}

variable "table_prefix" {
  description = "Prefixo para as tabelas do Glue"
  type        = string
  default     = ""
}

variable "enable_bookmark" {
  description = "Habilitar bookmark para jobs Glue"
  type        = bool
  default     = true
}

variable "enable_metrics" {
  description = "Habilitar métricas para jobs Glue"
  type        = bool
  default     = true
}

variable "enable_spark_ui" {
  description = "Habilitar Spark UI para jobs Glue"
  type        = bool
  default     = true
}

variable "additional_job_arguments" {
  description = "Argumentos adicionais para jobs Glue"
  type        = map(string)
  default     = {}
}
