###############################################################
# Módulo IAM
###############################################################

# modules/iam/main.tf
# IAM Role para o AWS Glue
resource "aws_iam_role" "glue_role" {
  name = "${var.project}-glue-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project}-glue-role"
    Environment = var.environment
    Project     = var.project
  }
}

# Anexando políticas AWS gerenciadas ao role do Glue
resource "aws_iam_role_policy_attachment" "glue_service" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# Política para acesso ao S3
resource "aws_iam_policy" "glue_s3_access" {
  name        = "${var.project}-glue-s3-access"
  description = "Permite que o AWS Glue acesse os buckets S3 do Data Lake"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          var.bucket_arns.bronze,
          "${var.bucket_arns.bronze}/*",
          var.bucket_arns.silver,
          "${var.bucket_arns.silver}/*",
          var.bucket_arns.gold,
          "${var.bucket_arns.gold}/*",
          var.bucket_arns.scripts,
          "${var.bucket_arns.scripts}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_s3_access" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_s3_access.arn
}

# Política para uso da KMS key
resource "aws_iam_policy" "glue_kms_access" {
  name        = "${var.project}-glue-kms-access"
  description = "Permite que o AWS Glue use a KMS key para criptografia/descriptografia"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = [
          var.kms_key_arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_kms_access" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_kms_access.arn
}

# IAM Role para Step Functions
resource "aws_iam_role" "step_functions_role" {
  name = "${var.project}-step-functions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project}-step-functions-role"
    Environment = var.environment
    Project     = var.project
  }
}

# Política para Step Functions controlar o Glue
resource "aws_iam_policy" "step_functions_glue_access" {
  name        = "${var.project}-step-functions-glue-access"
  description = "Permite que o Step Functions execute jobs e crawlers do Glue"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "glue:StartJobRun",
          "glue:GetJobRun",
          "glue:GetJobRuns",
          "glue:BatchStopJobRun",
          "glue:StartCrawler",
          "glue:StopCrawler",
          "glue:GetCrawler"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "step_functions_glue_access" {
  role       = aws_iam_role.step_functions_role.name
  policy_arn = aws_iam_policy.step_functions_glue_access.arn
}