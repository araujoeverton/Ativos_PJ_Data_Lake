# modules/glue-example-usage.tf

# Definição dos crawlers
locals {
  bronze_crawlers = {
    "customer_data" = {
      name          = "customer_data_crawler"
      database_name = var.glue_database_names.bronze
      s3_targets    = ["s3://${module.s3.bronze_bucket_name}/customers/"]
      description   = "Crawler para dados de clientes na camada bronze"
      schedule      = "cron(0 */4 * * ? *)"
    },
    "order_data" = {
      name          = "order_data_crawler"
      database_name = var.glue_database_names.bronze
      s3_targets    = ["s3://${module.s3.bronze_bucket_name}/orders/"]
      description   = "Crawler para dados de pedidos na camada bronze"
      schedule      = "cron(0 */4 * * ? *)"
    }
  }
  
  silver_crawlers = {
    "customer_data" = {
      name          = "customer_data_silver_crawler"
      database_name = var.glue_database_names.silver
      s3_targets    = ["s3://${module.s3.silver_bucket_name}/customers/"]
      description   = "Crawler para dados de clientes na camada silver"
    },
    "order_data" = {
      name          = "order_data_silver_crawler"
      database_name = var.glue_database_names.silver
      s3_targets    = ["s3://${module.s3.silver_bucket_name}/orders/"]
      description   = "Crawler para dados de pedidos na camada silver"
    }
  }
  
  gold_crawlers = {
    "customer_analytics" = {
      name          = "customer_analytics_crawler"
      database_name = var.glue_database_names.gold
      s3_targets    = ["s3://${module.s3.gold_bucket_name}/customer_analytics/"]
      description   = "Crawler para análises de clientes na camada gold"
    }
  }
  
  # Unir todos os crawlers em um único mapa
  all_crawlers = merge(local.bronze_crawlers, local.silver_crawlers, local.gold_crawlers)
}

# Definição dos jobs
locals {
  bronze_to_silver_jobs = {
    "customer_transform" = {
      name              = "customer_bronze_to_silver"
      script_path       = "bronze_to_silver/customer_transform.py"
      source_db         = var.glue_database_names.bronze
      target_db         = var.glue_database_names.silver
      source_path       = "s3://${module.s3.bronze_bucket_name}/customers/"
      target_path       = "s3://${module.s3.silver_bucket_name}/customers/"
      description       = "Transforma dados de clientes da camada bronze para silver"
    },
    "order_transform" = {
      name              = "order_bronze_to_silver"
      script_path       = "bronze_to_silver/order_transform.py"
      source_db         = var.glue_database_names.bronze
      target_db         = var.glue_database_names.silver
      source_path       = "s3://${module.s3.bronze_bucket_name}/orders/"
      target_path       = "s3://${module.s3.silver_bucket_name}/orders/"
      description       = "Transforma dados de pedidos da camada bronze para silver"
    }
  }
  
  silver_to_gold_jobs = {
    "customer_analytics" = {
      name              = "customer_analytics_job"
      script_path       = "silver_to_gold/customer_analytics.py"
      source_db         = var.glue_database_names.silver
      target_db         = var.glue_database_names.gold
      source_path       = "s3://${module.s3.silver_bucket_name}/"
      target_path       = "s3://${module.s3.gold_bucket_name}/customer_analytics/"
      description       = "Cria análises de clientes na camada gold"
      worker_type       = "G.2X"
      number_of_workers = 4
    }
  }
  
  # Unir todos os jobs em um único mapa
  all_jobs = merge(local.bronze_to_silver_jobs, local.silver_to_gold_jobs)
}