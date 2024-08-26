resource "aws_acm_certificate" "acm_cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = merge(
    {
      Name = "${data.terraform_remote_state.eks.outputs.cluster_id}-certificate"
    },
    local.common_tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

output "acm_certificate_id" {
  value = aws_acm_certificate.acm_cert.id
}

output "acm_certificate_arn" {
  value = aws_acm_certificate.acm_cert.arn
}

output "acm_certificate_status" {
  value = aws_acm_certificate.acm_cert.status
}