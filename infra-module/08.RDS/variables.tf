variable "aws_region" {
  description = "Region"
  type        = string
  default     = "eu-west-3"
}

variable "access_key" {
  description = "access_key"
  type        = string
}

variable "secret_key" {
  description = "secret_key"
  type        = string
}

variable "environment" {
  description = "Environment use as a prefix"
  type        = string
  default     = "dev"
}

variable "office" {
  description = "Office"
  type        = string
  default     = "sockshop"
}
