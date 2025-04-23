# Provider
provider "aws" {
  region = var.aws_region
}

# Dados do caller atual
data "aws_caller_identity" "current" {}

# Local para nomes de recursos
locals {
  account_id = data.aws_caller_identity.current.account_id
  athena_results_bucket = "${var.project}-athena-results-${var.environment}-${local.account_id}"
}

# Módulo S3 - Buckets para Data Lake
module "s3" {
  source = "./modules/s3"

  project     = var.project
  environment = var.environment
  
  bucket_names = {
    bronze  = "${var.project}-${var.data_lake_bucket_names.bronze}-${var.environment}-${local.account_id}"
    silver  = "${var.project}-${var.data_lake_bucket_names.silver}-${var.environment}-${local.account_id}"
    gold    = "${var.project}-${var.data_lake_bucket_names.gold}-${var.environment}-${local.account_id}"
    scripts = "${var.project}-${var.glue_scripts_bucket}-${var.environment}-${local.account_id}"
  }
  
  bronze_lifecycle_ia_days      = var.bronze_lifecycle_ia_days
  bronze_lifecycle_glacier_days = var.bronze_lifecycle_glacier_days
  silver_lifecycle_ia_days      = var.silver_lifecycle_ia_days
  gold_lifecycle_ia_days        = var.gold_lifecycle_ia_days
}

# Módulo IAM - Roles e Policies
module "iam" {
  source = "./modules/iam"

  project     = var.project
  environment = var.environment
  
  bucket_arns = {
    bronze  = module.s3.bronze_bucket_arn
    silver  = module.s3.silver_bucket_arn
    gold    = module.s3.gold_bucket_arn
    scripts = module.s3.scripts_bucket_arn
  }
  
  kms_key_arn = module.s3.kms_key_arn
}

# Módulo Lake Formation
module "lake_formation" {
  source = "./modules/lake-formation"

  data_lake_admin_arn = var.data_lake_admin_arn != null ? var.data_lake_admin_arn : data.aws_caller_identity.current.arn
  
  glue_role_arn = module.iam.glue_role_arn
  
  bucket_arns = {
    bronze = module.s3.bronze_bucket_arn
    silver = module.s3.silver_bucket_arn
    gold   = module.s3.gold_bucket_arn
  }
}

# Módulo Glue - Databases, Crawlers, Jobs
module "glue" {
  source = "./modules/glue"

  project     = var.project
  environment = var.environment
  
  glue_role_arn = module.iam.glue_role_arn
  
  database_names = var.glue_database_names
  crawler_names  = var.glue_crawler_names
  job_names      = var.glue_job_names
  
  buckets = {
    bronze  = module.s3.bronze_bucket_name
    silver  = module.s3.silver_bucket_name
    gold    = module.s3.gold_bucket_name
    scripts = module.s3.scripts_bucket_name
  }
  
  # Arquivos de script para Glue Jobs
  scripts = {
    bronze_to_silver = {
      source_path = "files/bronze_to_silver.py"
      target_key  = "scripts/bronze_to_silver.py"
    }
    silver_to_gold = {
      source_path = "files/silver_to_gold.py"
      target_key  = "scripts/silver_to_gold.py"
    }
  }
  
  depends_on = [module.lake_formation]
}

# Módulo Step Functions - State Machine para orquestração
module "step_functions" {
  source = "./modules/step-functions"

  project     = var.project
  environment = var.environment
  
  sfn_role_arn = module.iam.step_functions_role_arn
  
  # Recursos do Glue
  crawlers = {
    bronze = module.glue.bronze_crawler_name
    silver = module.glue.silver_crawler_name
    gold   = module.glue.gold_crawler_name
  }
  
  jobs = {
    bronze_to_silver = module.glue.bronze_to_silver_job_name
    silver_to_gold   = module.glue.silver_to_gold_job_name
  }
  
  schedule_expression = var.step_functions_schedule
}

# Módulo Athena - Para consultas ao Data Lake
module "athena" {
  source = "./modules/athena"

  project     = var.project
  environment = var.environment
  
  athena_results_bucket = local.athena_results_bucket
  kms_key_arn = module.s3.kms_key_arn
  
  glue_database_names = var.glue_database_names
}