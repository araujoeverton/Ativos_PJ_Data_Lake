###############################################################
# Módulo S3
###############################################################

# modules/s3/main.tf
resource "aws_kms_key" "datalake_key" {
  description             = "KMS key para criptografia do Data Lake"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name        = "${var.project}-datalake-key"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_kms_alias" "datalake_key_alias" {
  name          = "alias/${var.project}-datalake-key"
  target_key_id = aws_kms_key.datalake_key.key_id
}

# Bucket Bronze - Dados brutos
resource "aws_s3_bucket" "bronze" {
  bucket = var.bucket_names.bronze
  
  tags = {
    Name        = var.bucket_names.bronze
    Environment = var.environment
    Project     = var.project
    Layer       = "bronze"
  }
}

resource "aws_s3_bucket_versioning" "bronze_versioning" {
  bucket = aws_s3_bucket.bronze.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "bronze_lifecycle" {
  bucket = aws_s3_bucket.bronze.id

  rule {
    id     = "transition-to-ia-glacier"
    status = "Enabled"

    transition {
      days          = var.bronze_lifecycle_ia_days
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = var.bronze_lifecycle_glacier_days
      storage_class = "GLACIER"
    }
  }
}

# Bucket Silver - Dados processados e validados
resource "aws_s3_bucket" "silver" {
  bucket = var.bucket_names.silver
  
  tags = {
    Name        = var.bucket_names.silver
    Environment = var.environment
    Project     = var.project
    Layer       = "silver"
  }
}

resource "aws_s3_bucket_versioning" "silver_versioning" {
  bucket = aws_s3_bucket.silver.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "silver_lifecycle" {
  bucket = aws_s3_bucket.silver.id

  rule {
    id     = "transition-to-ia"
    status = "Enabled"

    transition {
      days          = var.silver_lifecycle_ia_days
      storage_class = "STANDARD_IA"
    }
  }
}

# Bucket Gold - Dados agregados e prontos para consumo
resource "aws_s3_bucket" "gold" {
  bucket = var.bucket_names.gold
  
  tags = {
    Name        = var.bucket_names.gold
    Environment = var.environment
    Project     = var.project
    Layer       = "gold"
  }
}

resource "aws_s3_bucket_versioning" "gold_versioning" {
  bucket = aws_s3_bucket.gold.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "gold_lifecycle" {
  bucket = aws_s3_bucket.gold.id

  rule {
    id     = "transition-to-ia"
    status = "Enabled"

    transition {
      days          = var.gold_lifecycle_ia_days
      storage_class = "STANDARD_IA"
    }
  }
}

# Bucket para scripts do Glue
resource "aws_s3_bucket" "scripts" {
  bucket = var.bucket_names.scripts
  
  tags = {
    Name        = var.bucket_names.scripts
    Environment = var.environment
    Project     = var.project
    Layer       = "scripts"
  }
}