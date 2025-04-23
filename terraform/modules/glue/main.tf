# modules/glue/main.tf (Versão Avançada)

# Databases do Glue Data Catalog para cada camada
resource "aws_glue_catalog_database" "bronze_db" {
  name        = var.database_names.bronze
  description = "Database para armazenar metadados da camada Bronze do Data Lake"
  
  parameters = {
    layer      = "bronze"
    project    = var.project
    environment = var.environment
    created_by = "terraform"
  }
}

resource "aws_glue_catalog_database" "silver_db" {
  name        = var.database_names.silver
  description = "Database para armazenar metadados da camada Silver do Data Lake"
  
  parameters = {
    layer      = "silver"
    project    = var.project
    environment = var.environment
    created_by = "terraform"
  }
}

resource "aws_glue_catalog_database" "gold_db" {
  name        = var.database_names.gold
  description = "Database para armazenar metadados da camada Gold do Data Lake"
  
  parameters = {
    layer      = "gold"
    project    = var.project
    environment = var.environment
    created_by = "terraform"
  }
}

# Crawler para a camada Bronze
resource "aws_glue_crawler" "bronze_crawler" {
  name          = var.crawler_names.bronze
  role          = var.glue_role_arn
  database_name = aws_glue_catalog_database.bronze_db.name
  description   = "Crawler para a camada Bronze do Data Lake"
  
  lake_formation_configuration {
    use_lake_formation_credentials = true
  }

  s3_target {
    path = "s3://${var.buckets.bronze}"
    exclusions = []
  }

  schema_change_policy {
    delete_behavior = var.crawler_schema_change_policy.delete_behavior
    update_behavior = var.crawler_schema_change_policy.update_behavior
  }

  configuration = jsonencode({
    Version = 1.0
    CrawlerOutput = {
      Partitions = { AddOrUpdateBehavior = "InheritFromTable" }
      Tables = { TableThreshold = 0 }
    }
    Grouping = {
      TableGroupingPolicy = "CombineCompatibleSchemas"
    }
  })

  lineage_configuration {
    crawler_lineage_settings = "ENABLE"
  }

  recrawl_policy {
    recrawl_behavior = "CRAWL_EVERYTHING"
  }
  
  schedule = var.crawler_schedule

  tags = {
    Name        = var.crawler_names.bronze
    Environment = var.environment
    Project     = var.project
    Layer       = "bronze"
  }
}

# Crawler para a camada Silver
resource "aws_glue_crawler" "silver_crawler" {
  name          = var.crawler_names.silver
  role          = var.glue_role_arn
  database_name = aws_glue_catalog_database.silver_db.name
  description   = "Crawler para a camada Silver do Data Lake"
  
  lake_formation_configuration {
    use_lake_formation_credentials = true
  }

  s3_target {
    path = "s3://${var.buckets.silver}"
    exclusions = []
  }

  schema_change_policy {
    delete_behavior = var.crawler_schema_change_policy.delete_behavior
    update_behavior = var.crawler_schema_change_policy.update_behavior
  }

  configuration = jsonencode({
    Version = 1.0
    CrawlerOutput = {
      Partitions = { AddOrUpdateBehavior = "InheritFromTable" }
      Tables = { TableThreshold = 0 }
    }
    Grouping = {
      TableGroupingPolicy = "CombineCompatibleSchemas"
    }
  })

  lineage_configuration {
    crawler_lineage_settings = "ENABLE"
  }

  recrawl_policy {
    recrawl_behavior = "CRAWL_EVERYTHING"
  }

  tags = {
    Name        = var.crawler_names.silver
    Environment = var.environment
    Project     = var.project
    Layer       = "silver"
  }
}

# Crawler para a camada Gold
resource "aws_glue_crawler" "gold_crawler" {
  name          = var.crawler_names.gold
  role          = var.glue_role_arn
  database_name = aws_glue_catalog_database.gold_db.name
  description   = "Crawler para a camada Gold do Data Lake"
  
  lake_formation_configuration {
    use_lake_formation_credentials = true
  }

  s3_target {
    path = "s3://${var.buckets.gold}"
    exclusions = []
  }

  schema_change_policy {
    delete_behavior = var.crawler_schema_change_policy.delete_behavior
    update_behavior = var.crawler_schema_change_policy.update_behavior
  }

  configuration = jsonencode({
    Version = 1.0
    CrawlerOutput = {
      Partitions = { AddOrUpdateBehavior = "InheritFromTable" }
      Tables = { TableThreshold = 0 }
    }
    Grouping = {
      TableGroupingPolicy = "CombineCompatibleSchemas"
    }
  })

  lineage_configuration {
    crawler_lineage_settings = "ENABLE"
  }

  recrawl_policy {
    recrawl_behavior = "CRAWL_EVERYTHING"
  }

  tags = {
    Name        = var.crawler_names.gold
    Environment = var.environment
    Project     = var.project
    Layer       = "gold"
  }
}

# Uploads de scripts para o bucket S3
resource "aws_s3_object" "bronze_to_silver_script" {
  bucket = var.buckets.scripts
  key    = var.scripts.bronze_to_silver.target_key
  source = var.scripts.bronze_to_silver.source_path
  etag   = filemd5(var.scripts.bronze_to_silver.source_path)

  tags = {
    Environment = var.environment
    Project     = var.project
    Layer       = "scripts"
    Job         = "bronze_to_silver"
  }
}

resource "aws_s3_object" "silver_to_gold_script" {
  bucket = var.buckets.scripts
  key    = var.scripts.silver_to_gold.target_key
  source = var.scripts.silver_to_gold.source_path
  etag   = filemd5(var.scripts.silver_to_gold.source_path)

  tags = {
    Environment = var.environment
    Project     = var.project
    Layer       = "scripts"
    Job         = "silver_to_gold"
  }
}

# Configurações comuns para jobs Glue
locals {
  common_job_arguments = {
    "--job-language"             = "python"
    "--continuous-log-logGroup"  = "/aws-glue/jobs"
    "--enable-job-insights"      = "true"
    "--enable-metrics"           = var.enable_metrics ? "true" : "false"
    "--enable-spark-ui"          = var.enable_spark_ui ? "true" : "false"
    "--spark-event-logs-path"    = "s3://${var.buckets.scripts}/spark-logs/"
    "--TempDir"                  = "s3://${var.buckets.scripts}/temp/"
    "--job-bookmark-option"      = var.enable_bookmark ? "job-bookmark-enable" : "job-bookmark-disable"
  }
}

# Job para transformar dados de Bronze para Silver
resource "aws_glue_job" "bronze_to_silver" {
  name              = var.job_names.bronze_to_silver
  role_arn          = var.glue_role_arn
  description       = "Job para transformar dados da camada Bronze para Silver"
  glue_version      = var.glue_version
  worker_type       = var.worker_type
  number_of_workers = var.number_of_workers
  timeout           = 60  # 60 minutos
  
  command {
    script_location = "s3://${var.buckets.scripts}/${var.scripts.bronze_to_silver.target_key}"
    python_version  = var.python_version
    name            = "glueetl"
  }

  execution_property {
    max_concurrent_runs = var.max_concurrent_runs
  }
  
  default_arguments = merge(
    local.common_job_arguments,
    {
      "--SOURCE_DATABASE"        = aws_glue_catalog_database.bronze_db.name
      "--TARGET_DATABASE"        = aws_glue_catalog_database.silver_db.name
      "--SOURCE_S3_BUCKET"       = var.buckets.bronze
      "--TARGET_S3_BUCKET"       = var.buckets.silver
      "--ENVIRONMENT"            = var.environment
      "--TABLE_PREFIX"           = var.table_prefix
    },
    var.additional_job_arguments
  )
  
  security_configuration = "" # Opcional: Configuração de segurança do Glue
  
  notification_property {
    notify_delay_after = 30  # Notificar após 30 minutos de atraso
  }

  tags = {
    Name        = var.job_names.bronze_to_silver
    Environment = var.environment
    Project     = var.project
    Layer       = "processing"
    Source      = "bronze"
    Target      = "silver"
  }
}

# Job para transformar dados de Silver para Gold
resource "aws_glue_job" "silver_to_gold" {
  name              = var.job_names.silver_to_gold
  role_arn          = var.glue_role_arn
  description       = "Job para transformar dados da camada Silver para Gold"
  glue_version      = var.glue_version
  worker_type       = var.worker_type
  number_of_workers = var.number_of_workers
  timeout           = 60  # 60 minutos
  
  command {
    script_location = "s3://${var.buckets.scripts}/${var.scripts.silver_to_gold.target_key}"
    python_version  = var.python_version
    name            = "glueetl"
  }

  execution_property {
    max_concurrent_runs = var.max_concurrent_runs
  }

  default_arguments = merge(
    local.common_job_arguments,
    {
      "--SOURCE_DATABASE"        = aws_glue_catalog_database.silver_db.name
      "--TARGET_DATABASE"        = aws_glue_catalog_database.gold_db.name
      "--SOURCE_S3_BUCKET"       = var.buckets.silver
      "--TARGET_S3_BUCKET"       = var.buckets.gold
      "--ENVIRONMENT"            = var.environment
      "--TABLE_PREFIX"           = var.table_prefix
    },
    var.additional_job_arguments
  )
  
  security_configuration = "" # Opcional: Configuração de segurança do Glue
  
  notification_property {
    notify_delay_after = 30  # Notificar após 30 minutos de atraso
  }

  tags = {
    Name        = var.job_names.silver_to_gold
    Environment = var.environment
    Project     = var.project
    Layer       = "processing"
    Source      = "silver"
    Target      = "gold"
  }
}

# Trigger para executar o crawler Bronze após ingestão de dados
resource "aws_glue_trigger" "trigger_bronze_crawler" {
  name          = "${var.crawler_names.bronze}_trigger"
  type          = "SCHEDULED"
  schedule      = var.crawler_schedule
  enabled       = true
  description   = "Trigger agendado para executar o crawler da camada Bronze"

  actions {
    crawler_name = aws_glue_crawler.bronze_crawler.name
  }

  tags = {
    Name        = "${var.crawler_names.bronze}_trigger"
    Environment = var.environment
    Project     = var.project
  }
}

# Trigger para executar o job Bronze to Silver após o crawler Bronze
resource "aws_glue_trigger" "trigger_bronze_to_silver_job" {
  name          = "${var.job_names.bronze_to_silver}_trigger"
  type          = "CONDITIONAL"
  description   = "Trigger condicional para executar o job Bronze to Silver após o crawler Bronze"
  
  predicate {
    conditions {
      crawler_name = aws_glue_crawler.bronze_crawler.name
      crawl_state  = "SUCCEEDED"
    }
  }

  actions {
    job_name = aws_glue_job.bronze_to_silver.name
  }

  tags = {
    Name        = "${var.job_names.bronze_to_silver}_trigger"
    Environment = var.environment
    Project     = var.project
  }
}

# Trigger para executar o crawler Silver após o job Bronze to Silver
resource "aws_glue_trigger" "trigger_silver_crawler" {
  name          = "${var.crawler_names.silver}_trigger"
  type          = "CONDITIONAL"
  description   = "Trigger condicional para executar o crawler Silver após o job Bronze to Silver"
  
  predicate {
    conditions {
      job_name = aws_glue_job.bronze_to_silver.name
      state    = "SUCCEEDED"
    }
  }

  actions {
    crawler_name = aws_glue_crawler.silver_crawler.name
  }

  tags = {
    Name        = "${var.crawler_names.silver}_trigger"
    Environment = var.environment
    Project     = var.project
  }
}

# Trigger para executar o job Silver to Gold após o crawler Silver
resource "aws_glue_trigger" "trigger_silver_to_gold_job" {
  name          = "${var.job_names.silver_to_gold}_trigger"
  type          = "CONDITIONAL"
  description   = "Trigger condicional para executar o job Silver to Gold após o crawler Silver"
  
  predicate {
    conditions {
      crawler_name = aws_glue_crawler.silver_crawler.name
      crawl_state  = "SUCCEEDED"
    }
  }

  actions {
    job_name = aws_glue_job.silver_to_gold.name
  }

  tags = {
    Name        = "${var.job_names.silver_to_gold}_trigger"
    Environment = var.environment
    Project     = var.project
  }
}

# Trigger para executar o crawler Gold após o job Silver to Gold
resource "aws_glue_trigger" "trigger_gold_crawler" {
  name          = "${var.crawler_names.gold}_trigger"
  type          = "CONDITIONAL"
  description   = "Trigger condicional para executar o crawler Gold após o job Silver to Gold"
  
  predicate {
    conditions {
      job_name = aws_glue_job.silver_to_gold.name
      state    = "SUCCEEDED"
    }
  }

  actions {
    crawler_name = aws_glue_crawler.gold_crawler.name
  }

  tags = {
    Name        = "${var.crawler_names.gold}_trigger"
    Environment = var.environment
    Project     = var.project
  }
}