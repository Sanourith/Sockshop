# EKS Sockshop

## Create key pair

- [https://eu-west-3.console.aws.amazon.com/ec2/home?region=eu-west-3#KeyPairs:](https://eu-west-3.console.aws.amazon.com/ec2/home?region=eu-west-3#KeyPairs)
- copy to ./private-key

## Backend S3

```bash
aws s3 mb s3://shopshosty-bucket-terraform-s3 --region eu-west-3 --endpoint-url https://s3.eu-west-3.amazonaws.com
```

## Options :  DynamoDB (Locking)

create a DynamoDB for loking.

- shopshosty-eks-vpc
- ... all modules ...

## Create EKS Cluster

```bash
terraform fmt
terraform init
terraform validate
terraform plan -out "tfplan"

terraform apply "tfplan"
# terraform apply "tfplan" -auto-approve
```

## Configure kubeconfig for kubectl

```bash
aws eks --region "eu-west-3" update-kubeconfig --name sockshop-dev-eks-sockshop
# aws eks --region <region-code> update-kubeconfig --name <cluster_name>

## Verify Kubernetes Worker Nodes using kubectl
kubectl get nodes
kubectl get nodes -o wide

## Terraform Destroy
terraform destroy -auto-approve

## Delete Terraform Provider Plugins
rm -rf .terraform
```
