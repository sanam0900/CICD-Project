output "db_host" {
  description = "Database endpoint"
  value       = aws_db_instance.db.address
}

output "db_port" {
  description = "Database port"
  value       = aws_db_instance.db.port
}

output "db_name" {
  description = "Database name"
  value       = var.db_name
}