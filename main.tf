# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      HashiCorpLearnTutorial = "no-code-provisioning"
    }
  }
}

provider "random" {}

data "aws_availability_zones" "available" {}

resource "random_pet" "random" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"

  name                 = "${random_pet.random.id}-education"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_db_subnet_group" "education" {
  name       = "${random_pet.random.id}-education"
  subnet_ids = module.vpc.public_subnets

  tags = {
    Name = "${random_pet.random.id} Education"
  }
}

resource "aws_security_group" "rds" {
  name   = "${random_pet.random.id}-education_rds"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["192.80.0.0/16"]
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${random_pet.random.id}-education_rds"
  }
}

resource "aws_db_parameter_group" "education" {
  name   = "${random_pet.random.id}-education"
  family = "postgres16"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  lifecycle {
    create_before_destroy = true
  }
}

ephemeral "random_password" "db_password" {
  length  = 16
  special = false
}

locals {
  # Increment db_password_version to update the DB password and store the new
  # password in SSM.
  db_password_version = 1
}

resource "aws_db_instance" "education" {
  identifier             = "${var.db_name}-${random_pet.random.id}"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  apply_immediately      = true
  engine                 = "postgres"
  engine_version         = "16"
  username               = var.db_username
  password_wo            = ephemeral.random_password.db_password.result
  password_wo_version    = local.db_password_version
  db_subnet_group_name   = aws_db_subnet_group.education.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.education.name
  publicly_accessible    = true
  skip_final_snapshot    = true
}

resource "aws_ssm_parameter" "secret" {
  name             = "/education/database/${var.db_name}/password/master"
  description      = "Password for RDS database."
  type             = "SecureString"
  value_wo         = ephemeral.random_password.db_password.result
  value_wo_version = local.db_password_version
}
