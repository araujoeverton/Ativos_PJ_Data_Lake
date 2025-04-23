# main.tf (Arquivo Principal Corrigido)

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
  
  # Definição dos crawlers
  bronze_crawlers = {
    "customer_data" = {
      name          = "customer_data_crawler"
      database_name = var.glue_database_names.bronze
      s3_targets    = ["s3://${var.project}-${var.data_lake_bucket_names.bronze}-${var.environment}-${local.account_id}/customers/"]
      description   = "Crawler para dados de clientes na camada bronze"
      schedule      = "cron(0 */4 * * ? *)"
    },
    "order_data" = {
      name          = "order_data_crawler"
      database_name = var.glue_database_names.bronze
      s3_targets    = ["s3://${var.project}-${var.data_lake_bucket_names.bronze}-${var.environment}-${local.account_id}/orders/"]
      description   = "Crawler para dados de pedidos na camada bronze"
      schedule      = "cron(0 */4 * * ? *)"
    }
  }
  
  silver_crawlers = {
    "customer_data" = {
      name          = "customer_data_silver_crawler"
      database_name = var.glue_database_names.silver
      s3_targets    = ["s3://${var.project}-${var.data_lake_bucket_names.silver}-${var.environment}-${local.account_id}/customers/"]
      description   = "Crawler para dados de clientes na camada silver"
    },
    "order_data" = {
      name          = "order_data_silver_crawler"
      database_name = var.glue_database_names.silver
      s3_targets    = ["s3://${var.project}-${var.data_lake_bucket_names.silver}-${var.environment}-${local.account_id}/orders/"]
      description   = "Crawler para dados de pedidos na camada silver"
    }
  }
  
  gold_crawlers = {
    "customer_analytics" = {
      name          = "customer_analytics_crawler"
      database_name = var.glue_database_names.gold
      s3_targets    = ["s3://${var.project}-${var.data_lake_bucket_names.gold}-${var.environment}-${local.account_id}/customer_analytics/"]
      description   = "Crawler para análises de clientes na camada gold"
    }
  }
  
  # Unir todos os crawlers em um único mapa
  all_crawlers = merge(local.bronze_crawlers, local.silver_crawlers, local.gold_crawlers)
  
  # Definição dos jobs
  bronze_to_silver_jobs = {
    "customer_transform" = {
      name              = "customer_bronze_to_silver"
      script_path       = "bronze_to_silver/customer_transform.py"
      source_db         = var.glue_database_names.bronze
      target_db         = var.glue_database_names.silver
      source_path       = "s3://${var.project}-${var.data_lake_bucket_names.bronze}-${var.environment}-${local.account_id}/customers/"
      target_path       = "s3://${var.project}-${var.data_lake_bucket_names.silver}-${var.environment}-${local.account_id}/customers/"
      description       = "Transforma dados de clientes da camada bronze para silver"
    },
    "order_transform" = {
      name              = "order_bronze_to_silver"
      script_path       = "bronze_to_silver/order_transform.py"
      source_db         = var.glue_database_names.bronze
      target_db         = var.glue_database_names.silver
      source_path       = "s3://${var.project}-${var.data_lake_bucket_names.bronze}-${var.environment}-${local.account_id}/orders/"
      target_path       = "s3://${var.project}-${var.data_lake_bucket_names.silver}-${var.environment}-${local.account_id}/orders/"
      description       = "Transforma dados de pedidos da camada bronze para silver"
    }
  }
  
  silver_to_gold_jobs = {
    "customer_analytics" = {
      name              = "customer_analytics_job"
      script_path       = "silver_to_gold/customer_analytics.py"
      source_db         = var.glue_database_names.silver
      target_db         = var.glue_database_names.gold
      source_path       = "s3://${var.project}-${var.data_lake_bucket_names.silver}-${var.environment}-${local.account_id}/"
      target_path       = "s3://${var.project}-${var.data_lake_bucket_names.gold}-${var.environment}-${local.account_id}/customer_analytics/"
      description       = "Cria análises de clientes na camada gold"
      worker_type       = "G.2X"
      number_of_workers = 4
    }
  }
  
  # Unir todos os jobs em um único mapa
  all_jobs = merge(local.bronze_to_silver_jobs, local.silver_to_gold_jobs)
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
  
  # Passando os crawlers e jobs configurados
  crawlers = local.all_crawlers
  jobs     = local.all_jobs
  
  # Caminho base para os scripts
  scripts_base_path = "scripts"
  
  buckets = {
    bronze  = module.s3.bronze_bucket_name
    silver  = module.s3.silver_bucket_name
    gold    = module.s3.gold_bucket_name
    scripts = module.s3.scripts_bucket_name
  }
  
  depends_on = [module.lake_formation]
}

# Módulo Step Functions - State Machine para orquestração
module "step_functions" {
  source = "./modules/step-functions"

  project     = var.project
  environment = var.environment
  
  sfn_role_arn = module.iam.step_functions_role_arn
  
  # Recursos do Glue - Usar os primeiros crawlers e jobs
  # como representantes de cada camada para o Step Functions
  crawlers = {
    bronze = local.bronze_crawlers["customer_data"].name
    silver = local.silver_crawlers["customer_data"].name
    gold   = local.gold_crawlers["customer_analytics"].name
  }
  
  jobs = {
    bronze_to_silver = local.bronze_to_silver_jobs["customer_transform"].name
    silver_to_gold   = local.silver_to_gold_jobs["customer_analytics"].name
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