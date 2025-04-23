# modules/athena/variables.tf
variable "project" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, stg, prd)"
  type        = string
}

variable "athena_results_bucket" {
  description = "Nome do bucket para resultados do Athena"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN da KMS key"
  type        = string
}

variable "glue_database_names" {
  description = "Nomes dos bancos de dados Glue"
  type        = map(string)
}