###############################################################
# Módulo Lake Formation
###############################################################

# modules/lake-formation/main.tf
# Configuração inicial do Lake Formation
resource "aws_lakeformation_data_lake_settings" "datalake_settings" {
  admins = [var.data_lake_admin_arn]
}

# Registrar os buckets no Lake Formation
resource "aws_lakeformation_resource" "bronze_bucket" {
  arn = var.bucket_arns.bronze

  role_arn = var.glue_role_arn
}

resource "aws_lakeformation_resource" "silver_bucket" {
  arn = var.bucket_arns.silver

  role_arn = var.glue_role_arn
}

resource "aws_lakeformation_resource" "gold_bucket" {
  arn = var.bucket_arns.gold

  role_arn = var.glue_role_arn
}

# Conceder permissões de localização de dados no Lake Formation
resource "aws_lakeformation_permissions" "glue_data_location_bronze" {
  principal   = var.glue_role_arn
  permissions = ["DATA_LOCATION_ACCESS"]

  data_location {
    arn = var.bucket_arns.bronze
  }
}

resource "aws_lakeformation_permissions" "glue_data_location_silver" {
  principal   = var.glue_role_arn
  permissions = ["DATA_LOCATION_ACCESS"]

  data_location {
    arn = var.bucket_arns.silver
  }
}

resource "aws_lakeformation_permissions" "glue_data_location_gold" {
  principal   = var.glue_role_arn
  permissions = ["DATA_LOCATION_ACCESS"]

  data_location {
    arn = var.bucket_arns.gold
  }
}