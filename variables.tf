# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "db_name" {
  description = "Unique name to assign to RDS instance."
  type        = string
}

variable "db_username" {
  description = "RDS root username."
  type        = string
}

variable "db_password" {
  description = "RDS root user password."
  type        = string
  sensitive   = true
}
