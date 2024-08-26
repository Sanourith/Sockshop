locals {
  owners      = var.office
  environment = var.environment
  name        = "${var.office}-${var.environment}"

  common_tags = {
    owners      = local.owners
    environment = local.environment
  }
  eks_cluster_name = "${local.name}-${var.cluster_name}"
}

module "vpc" {
  source           = "./modules/vpc"
  common_tags      = local.common_tags
  eks_cluster_name = local.eks_cluster_name

  vpc_name            = var.vpc_name
  vpc_cidr_block      = var.vpc_cidr_block
  vpc_public_subnets  = var.vpc_public_subnets
  vpc_private_subnets = var.vpc_private_subnets

  vpc_database_subnets                   = var.vpc_database_subnets
  vpc_create_database_subnet_group       = var.vpc_create_database_subnet_group
  vpc_create_database_subnet_route_table = var.vpc_create_database_subnet_route_table

  vpc_enable_nat_gateway = var.vpc_enable_nat_gateway
  vpc_single_nat_gateway = var.vpc_single_nat_gateway
}

module "eks" {
  source          = "./modules/eks"
  name            = local.name
  public_subnets  = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets
  cluster_name    = local.eks_cluster_name
  cluster_version = var.cluster_version
  vpc_id          = module.vpc.vpc_id
  depends_on      = [module.vpc]
}

data "aws_eks_cluster_auth" "cluster" {
  # name = aws_eks_cluster.eks_cluster.id
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

module "oidc" {
  source       = "./modules/oidc"
  cluster_name = var.cluster_name
  issuer       = module.eks.cluster_oidc_issuer_url

  depends_on = [module.eks]
}

