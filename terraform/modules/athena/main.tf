# modules/athena/main.tf
# Bucket para armazenar resultados de consultas do Athena
resource "aws_s3_bucket" "athena_results" {
  bucket = var.athena_results_bucket
  
  tags = {
    Name        = var.athena_results_bucket
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_s3_bucket_versioning" "athena_results_versioning" {
  bucket = aws_s3_bucket.athena_results.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Configuração do grupo de trabalho do Athena
resource "aws_athena_workgroup" "datalake_workgroup" {
  name = "${var.project}-workgroup"

  configuration {
    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena_results.bucket}/"
      
      encryption_configuration {
        encryption_option = "SSE_KMS"
        kms_key_arn       = var.kms_key_arn
      }
    }
  }

  tags = {
    Name        = "${var.project}-workgroup"
    Environment = var.environment
    Project     = var.project
  }
}

# Exemplos de consultas pré-definidas
resource "aws_athena_named_query" "bronze_tables" {
  name        = "${var.project}_show_bronze_tables"
  workgroup   = aws_athena_workgroup.datalake_workgroup.name
  database    = var.glue_database_names.bronze
  query       = "SHOW TABLES IN ${var.glue_database_names.bronze};"
  description = "Lista todas as tabelas no banco de dados Bronze"
}

resource "aws_athena_named_query" "silver_tables" {
  name        = "${var.project}_show_silver_tables"
  workgroup   = aws_athena_workgroup.datalake_workgroup.name
  database    = var.glue_database_names.silver
  query       = "SHOW TABLES IN ${var.glue_database_names.silver};"
  description = "Lista todas as tabelas no banco de dados Silver"
}

resource "aws_athena_named_query" "gold_tables" {
  name        = "${var.project}_show_gold_tables"
  workgroup   = aws_athena_workgroup.datalake_workgroup.name
  database    = var.glue_database_names.gold
  query       = "SHOW TABLES IN ${var.glue_database_names.gold};"
  description = "Lista todas as tabelas no banco de dados Gold"
}