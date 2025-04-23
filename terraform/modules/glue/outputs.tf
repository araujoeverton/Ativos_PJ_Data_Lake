# modules/glue/outputs.tf
output "database_names" {
  description = "Nomes dos bancos de dados criados"
  value = {
    bronze = aws_glue_catalog_database.bronze_db.name
    silver = aws_glue_catalog_database.silver_db.name
    gold   = aws_glue_catalog_database.gold_db.name
  }
}

output "crawler_details" {
  description = "Detalhes dos crawlers criados"
  value = {
    for name, crawler in aws_glue_crawler.crawlers : name => {
      id   = crawler.id
      name = crawler.name
      arn  = crawler.arn
    }
  }
}

output "job_details" {
  description = "Detalhes dos jobs criados"
  value = {
    for name, job in aws_glue_job.jobs : name => {
      id         = job.id
      name       = job.name
      arn        = job.arn
      script_loc = "s3://${var.buckets.scripts}/scripts/${var.jobs[name].script_path}"
    }
  }
}

output "trigger_details" {
  description = "Detalhes dos triggers criados"
  value = {
    for name, trigger in aws_glue_trigger.job_schedules : name => {
      id   = trigger.id
      name = trigger.name
      arn  = trigger.arn
    }
  }
}