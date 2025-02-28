# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "region" {
  description = "AWS region for all resources."
  type        = string
  default     = "us-east-2"
}

variable "db_name" {
  description = "Unique name to assign to RDS instance."
  type        = string
}

variable "db_username" {
  description = "RDS root username."
  type        = string
}

variable "db_encrypted" {
  description = "Encrypt the database storage"
  type = bool
}
