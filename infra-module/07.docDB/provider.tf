terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.31"
    }
  }
  backend "s3" {
    bucket = "shopshosty-bucket-terraform-s3"
    key    = "shopshosty/docdb/terraform.tfstate"
    region = "eu-west-3"

    # dynamodb_table = "shopshosty-bastion"
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.access_key
  secret_key = var.secret_key
}
