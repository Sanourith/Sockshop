data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "shopshosty-bucket-terraform-s3"
    key    = "shopshosty/eks-vpc/terraform.tfstate"
    region = var.aws_region
  }
}

locals {
  owners      = var.office
  environment = var.environment
  name        = "${var.office}-${var.environment}"
  common_tags = {
    owners      = local.owners
    environment = local.environment
  }
}

resource "aws_iam_policy" "cert_manager_iam_policy" {
  depends_on  = [aws_acm_certificate.acm_cert]
  name        = "${local.name}-AllowPolicyForCertManager"
  path        = "/"
  description = "External DNS IAM Policy"
  # policy = jsonencode({
  #   "Version" : "2012-10-17",
  #   "Statement" : [
  #     {
  #       "Effect" : "Allow",
  #       "Action" : [
  #         "route53:ChangeResourceRecordSets"
  #       ],
  #       "Resource" : [
  #         "arn:aws:route53:::hostedzone/*"
  #       ]
  #     },
  #     {
  #       "Effect" : "Allow",
  #       "Action" : [
  #         "route53:ListHostedZones",
  #         "route53:ListResourceRecordSets",
  #         "route53:ListTagsForResource"
  #       ],
  #       "Resource" : [
  #         "*"
  #       ]
  #     }
  #   ]
  # })  
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "route53:GetChange",
        "Resource" : "arn:aws:route53:::change/*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:ChangeResourceRecordSets",
          "route53:ListResourceRecordSets",
          "route53:ListTagsForResource"
        ],
        "Resource" : [
          "arn:aws:route53:::hostedzone/${aws_acm_certificate.acm_cert.id}"
        ]
      }
    ]
  })
}

output "cert_manager_iam_policy_arn" {
  value = aws_iam_policy.cert_manager_iam_policy.arn
}

resource "aws_iam_role" "cert_manager_iam_role" {
  name = "${local.name}-cert-manager-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = "${data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_arn}"
        }
        Condition = {
          StringEquals = {
            "${data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_extract_from_arn}:aud" : "sts.amazonaws.com",
            "${data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_extract_from_arn}:sub" : "system:serviceaccount:cert-manager:cert-manager"
          }
        }
      },
    ]
  })

  tags = {
    tag-key = "AllowPolicyForCertManager"
  }
}

resource "aws_iam_role_policy_attachment" "cert_manager_iam_role_policy_attach" {
  policy_arn = aws_iam_policy.cert_manager_iam_policy.arn
  role       = aws_iam_role.cert_manager_iam_role.name
}

output "cert_manager_iam_role_arn" {
  description = "Cert Manager IAM Role ARN"
  value       = aws_iam_role.cert_manager_iam_role.arn
}

resource "helm_release" "cert_manager" {
  depends_on = [aws_iam_role.cert_manager_iam_role]

  create_namespace = true
  name             = "cert-manager"

  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"

  namespace = "cert-manager"

  # set {
  #   name  = "image.repository"
  #   value = "registry.k8s.io/external-dns/external-dns"
  # }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "cert-manager"
  }

  set {
    name  = "crds.enabled"
    value = "true"
  }

  # set {
  #   name  = "webhook.hostNetwork"
  #   value = "true"
  # }

  # set {
  #   name  = "webhook.securePort"
  #   value = 10250
  # }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.cert_manager_iam_role.arn
  }

}

# resource "kubernetes_namespace_v1" "example" {
#   metadata {
#     annotations = {
#       name = "example-annotation"
#     }

#     labels = {
#       mylabel = "label-value"
#     }

#     name = "terraform-example-namespace"
#   }
# }


