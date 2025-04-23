# modules/lake-formation/outputs.tf
output "lake_formation_resources" {
  description = "Recursos registrados no Lake Formation"
  value = {
    bronze = aws_lakeformation_resource.bronze_bucket.arn
    silver = aws_lakeformation_resource.silver_bucket.arn
    gold   = aws_lakeformation_resource.gold_bucket.arn
  }
}