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

# Definição para permitir múltiplos crawlers
variable "crawlers" {
  description = "Configuração para múltiplos crawlers"
  type = map(object({
    name          = string
    database_name = string
    s3_targets    = list(string)
    description   = string
    schedule      = optional(string)
    table_prefix  = optional(string)
    exclusions    = optional(list(string), [])
  }))
  # Exemplo:
  # crawlers = {
  #   "customer_data" = {
  #     name          = "customer_data_crawler"
  #     database_name = "bronze_db"
  #     s3_targets    = ["s3://bucket-bronze/customers/", "s3://bucket-bronze/orders/"]
  #     description   = "Crawler para dados de clientes"
  #     schedule      = "cron(0 12 * * ? *)"
  #   }
  # }
}

# Definição para permitir múltiplos jobs
variable "jobs" {
  description = "Configuração para múltiplos jobs"
  type = map(object({
    name              = string
    script_path       = string
    source_db         = string
    target_db         = string
    source_path       = string
    target_path       = string
    worker_type       = optional(string, "G.1X")
    number_of_workers = optional(number, 2)
    max_retries       = optional(number, 0)
    timeout           = optional(number, 60)
    description       = optional(string, "")
    schedule          = optional(string, "")
    additional_args   = optional(map(string), {})
  }))
  # Exemplo:
  # jobs = {
  #   "customer_bronze_to_silver" = {
  #     name          = "customer_bronze_to_silver_job"
  #     script_path   = "bronze_to_silver/customer_transform.py"
  #     source_db     = "bronze_db"
  #     target_db     = "silver_db"
  #     source_path   = "s3://bucket-bronze/customers/"
  #     target_path   = "s3://bucket-silver/customers/"
  #   }
  # }
}

variable "scripts_base_path" {
  description = "Caminho base local para os scripts"
  type        = string
  default     = "files/scripts"
}

variable "buckets" {
  description = "Nomes dos buckets S3"
  type        = map(string)
}

variable "glue_version" {
  description = "Versão do Glue a ser utilizada"
  type        = string
  default     = "3.0"
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