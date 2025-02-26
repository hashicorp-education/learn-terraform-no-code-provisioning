# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "region" {
  description = "AWS region for all resources."
  value       = var.region
}

output "rds_hostname" {
  description = "RDS instance hostname."
  value       = aws_db_instance.education.address
}

output "rds_port" {
  description = "RDS instance port."
  value       = aws_db_instance.education.port
  sensitive   = true
}

output "rds_dbname" {
  description = "RDS instance database name."
  value       = var.db_name
  sensitive   = true
}

output "rds_username" {
  description = "RDS instance root username."
  value       = aws_db_instance.education.username
  sensitive   = true
}

