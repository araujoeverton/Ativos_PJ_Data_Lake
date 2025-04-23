# modules/glue/main.tf
# Databases do Glue Data Catalog para cada camada
resource "aws_glue_catalog_database" "bronze_db" {
  name = var.database_names.bronze
}

resource "aws_glue_catalog_database" "silver_db" {
  name = var.database_names.silver
}

resource "aws_glue_catalog_database" "gold_db" {
  name = var.database_names.gold
}

# Múltiplos crawlers conforme configuração
resource "aws_glue_crawler" "crawlers" {
  for_each      = var.crawlers
  
  name          = each.value.name
  description   = each.value.description
  role          = var.glue_role_arn
  database_name = each.value.database_name
  schedule      = each.value.schedule
  
  lake_formation_configuration {
    use_lake_formation_credentials = true
  }

  # Múltiplos alvos S3 para o mesmo crawler
  dynamic "s3_target" {
    for_each = each.value.s3_targets
    content {
      path       = s3_target.value
      exclusions = each.value.exclusions
    }
  }

  schema_change_policy {
    delete_behavior = var.crawler_schema_change_policy.delete_behavior
    update_behavior = var.crawler_schema_change_policy.update_behavior
  }

  # Configurações avançadas
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

  # Habilitar lineage para rastreamento
  lineage_configuration {
    crawler_lineage_settings = "ENABLE"
  }

  # Configuração para sempre verificar todos os arquivos
  recrawl_policy {
    recrawl_behavior = "CRAWL_EVERYTHING"
  }

  # Configuração de prefixo de tabela, se fornecido
  table_prefix = each.value.table_prefix != null ? each.value.table_prefix : ""

  tags = {
    Name        = each.value.name
    Environment = var.environment
    Project     = var.project
  }
}

# Upload dos scripts para o bucket S3
resource "aws_s3_object" "job_scripts" {
  for_each = var.jobs
  
  bucket = var.buckets.scripts
  # Destino no S3 mantendo a estrutura de pastas
  key    = "scripts/${each.value.script_path}"
  # Origem do arquivo local
  source = "${var.scripts_base_path}/${each.value.script_path}"
  # Garantir atualização se o script mudar
  etag   = filemd5("${var.scripts_base_path}/${each.value.script_path}")

  tags = {
    Environment = var.environment
    Project     = var.project
    Job         = each.key
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

# Múltiplos jobs Glue conforme configuração
resource "aws_glue_job" "jobs" {
  for_each          = var.jobs
  
  name              = each.value.name
  description       = each.value.description
  role_arn          = var.glue_role_arn
  glue_version      = var.glue_version
  worker_type       = each.value.worker_type
  number_of_workers = each.value.number_of_workers
  timeout           = each.value.timeout
  max_retries       = each.value.max_retries
  
  command {
    script_location = "s3://${var.buckets.scripts}/scripts/${each.value.script_path}"
    python_version  = var.python_version
    name            = "glueetl"
  }

  execution_property {
    max_concurrent_runs = 1
  }
  
  # Argumentos específicos do job + argumentos comuns
  default_arguments = merge(
    local.common_job_arguments,
    {
      "--SOURCE_DATABASE"        = each.value.source_db
      "--TARGET_DATABASE"        = each.value.target_db
      "--SOURCE_PATH"            = each.value.source_path
      "--TARGET_PATH"            = each.value.target_path
      "--ENVIRONMENT"            = var.environment
    },
    each.value.additional_args
  )
  
  notification_property {
    notify_delay_after = 30  # Notificar após 30 minutos de atraso
  }

  tags = {
    Name        = each.value.name
    Environment = var.environment
    Project     = var.project
    SourceDB    = each.value.source_db
    TargetDB    = each.value.target_db
  }
}

# Criação de triggers para os jobs (opcional baseado no schedule)
resource "aws_glue_trigger" "job_schedules" {
  for_each    = { for k, v in var.jobs : k => v if v.schedule != "" }
  
  name        = "${each.value.name}_schedule"
  type        = "SCHEDULED"
  schedule    = each.value.schedule
  description = "Agendamento para o job ${each.value.name}"
  
  actions {
    job_name = aws_glue_job.jobs[each.key].name
  }
  
  tags = {
    Name        = "${each.value.name}_schedule"
    Environment = var.environment
    Project     = var.project
  }
}
