# modules/iam/variables.tf
variable "project" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, stg, prd)"
  type        = string
}

variable "bucket_arns" {
  description = "ARNs dos buckets S3"
  type        = map(string)
}

variable "kms_key_arn" {
  description = "ARN da KMS key"
  type        = string
}