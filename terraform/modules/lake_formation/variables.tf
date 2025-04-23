# modules/lake-formation/variables.tf
variable "data_lake_admin_arn" {
  description = "ARN do IAM Role/User que será administrador do Lake Formation"
  type        = string
}

variable "glue_role_arn" {
  description = "ARN da IAM role para o Glue"
  type        = string
}

variable "bucket_arns" {
  description = "ARNs dos buckets S3"
  type        = map(string)
}