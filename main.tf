# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.77.0"

  name                 = "lanchonetebairro_db"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_db_subnet_group" "lanchonetebairro_db" {
  name       = "lanchonetebairro_db"
  subnet_ids = module.vpc.public_subnets

  tags = {
    Name = "lanchonetebairro"
  }
}

resource "aws_security_group" "maria_db" {
  name   = "lanchonetebairro_maria_db"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lanchonetebairro_maria_db"
  }
}

resource "aws_db_parameter_group" "lanchonetebairro" {
  name   = "lanchonetebairro"
  family = "mariadb10.6"
}

resource "aws_db_instance" "lanchonetebairro" {
  identifier             = "lanchonetebairro"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "mariadb"
  engine_version         = "10.6.10"
  username               = "root"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.lanchonetebairro_db.name
  vpc_security_group_ids = [aws_security_group.maria_db.id]
  parameter_group_name   = aws_db_parameter_group.lanchonetebairro.name
  publicly_accessible    = true
  skip_final_snapshot    = true
}
