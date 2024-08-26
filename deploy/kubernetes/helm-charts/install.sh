#!/usr/bin/env bash

# Installation https://kubernetes-sigs.github.io/aws-load-balancer-controller
# helm repo add eks https://aws.github.io/eks-charts

# helm upgrade --install \
#   -n kube-system \
#   --set clusterName="$(terraform output -raw cluster_name)" \
#   --set serviceAccount.create=true \
#   aws-load-balancer-controller eks/aws-load-balancer-controller

# rattaché la policy eks-admin au node-group 

helm upgrade -i cart "./cart" --values="./cart/values.yaml" --namespace default
helm upgrade -i catalogue "./catalogue" --values="./catalogue/values.yaml" --namespace default
helm upgrade -i frontend "./front-end" --values="./front-end/values.yaml" --namespace default
# helm upgrade -i frontend "./front-end" --values="./front-end/values.yaml" --namespace default --set ssl.enabled=true
helm upgrade -i order "./order" --values="./order/values.yaml" --namespace default
helm upgrade -i payment "./payment" --values="./payment/values.yaml" --namespace default
helm upgrade -i queue-master "./queue-master" --values="./queue-master/values.yaml" --namespace default 
helm upgrade -i rabbitmq "./rabbitmq" --values="./rabbitmq/values.yaml" --namespace default
helm upgrade -i session "./session" --values="./session/values.yaml" --namespace default
helm upgrade -i shipping "./shipping" --values="./shipping/values.yaml" --namespace default
helm upgrade -i user "./user" --values="./user/values.yaml" --namespace default
# helm upgrade -i zipkin "./cart" --values="./cart/values.yaml" --namespace default