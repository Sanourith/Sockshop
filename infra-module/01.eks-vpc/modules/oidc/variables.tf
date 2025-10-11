variable "eks_oidc_root_ca_thumbprint" {
  type        = string
  description = "Thumbprint of Root CA for EKS OIDC, Valid until 2037"
  default     = "9e99a48a9960b14926bb7f3b02e22da2b0ab7280"
}

variable "common_tags" {
  type = map(string)
  default = {
    owners      = "architect"
    environment = "dev"
  }
}

variable "cluster_name" {
  type = string
}

variable "issuer" {
  type = string
}