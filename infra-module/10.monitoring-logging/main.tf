data "terraform_remote_state" "eks" {
  backend = "s3"
  # workspace = 
  config = {
    bucket = "shopshosty-bucket-terraform-s3"
    key    = "shopshosty/eks-vpc/terraform.tfstate"
    region = var.aws_region
  }
}

# Define Local Values in Terraform
locals {
  owners      = var.office
  environment = var.environment
  name        = "${var.office}-${var.environment}"
  common_tags = {
    owners      = local.owners
    environment = local.environment
  }
  eks_cluster_name = data.terraform_remote_state.eks.outputs.cluster_id
} 
