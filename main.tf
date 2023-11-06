# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.77.0"

  name                 = "lanchonetebairro"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_db_subnet_group" "lanchonetebairro" {
  name       = "lanchonetebairro"
  subnet_ids = module.vpc.public_subnets

  tags = {
    Name = "lanchonetebairro"
  }
}

resource "aws_security_group" "rds" {
  name   = "lanchonetebairro_rds"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lanchonetebairro_rds"
  }
}

resource "aws_db_parameter_group" "lanchonetebairro" {
  name   = "lanchonetebairro"
  family = "mariadb10.6"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}

resource "aws_db_instance" "lanchonetebairro" {
  identifier             = "lanchonetebairro"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "mariadb"
  engine_version         = "10.6.10"
  username               = "root"
  password               = ${{ secrets.DB_PASSWORD }}
  db_subnet_group_name   = aws_db_subnet_group.lanchonetebairro.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.lanchonetebairro.name
  publicly_accessible    = true
  skip_final_snapshot    = true
}
