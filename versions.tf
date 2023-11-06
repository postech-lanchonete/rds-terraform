# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.20.0"
    }
  }

  backend "remote" {
      hostname = "app.terraform.io"
      organization = "lanchonetebairro"

      workspaces {
        name = "lanchonete-db"
      }
    }
  }
}
