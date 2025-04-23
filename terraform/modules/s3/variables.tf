# modules/s3/variables.tf
variable "project" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, stg, prd)"
  type        = string
}

variable "bucket_names" {
  description = "Nomes dos buckets"
  type        = map(string)
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