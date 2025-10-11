terraform {
  required_version = ">= 1.6.0"
  required_providers {
    null = {
      source = "hashicorp/null"
      version = "~> 3.1"
    }
  }
  backend "s3" {
    bucket = "shopshosty-bucket-terraform-s3"
    key    = "shopshosty/vpa/terraform.tfstate"
    region = "eu-west-3"

    #dynamodb_table = "shopshosty-vpa"    
  }     
}

provider "null" {}