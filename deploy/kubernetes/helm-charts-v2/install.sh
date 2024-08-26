#!/usr/bin/env bash

# Installation https://kubernetes-sigs.github.io/aws-load-balancer-controller
# helm repo add eks https://aws.github.io/eks-charts

# helm upgrade --install \
#   -n kube-system \
#   --set clusterName="$(terraform output -raw cluster_name)" \
#   --set serviceAccount.create=true \
#   aws-load-balancer-controller eks/aws-load-balancer-controller

# rattaché la policy eks-admin au node-group 

helm upgrade -i cart "./cart" --values="./cart/values.yaml" --namespace sock-shop
helm upgrade -i catalogue "./catalogue" --values="./catalogue/values.yaml" --namespace sock-shop
helm upgrade -i frontend "./front-end" --values="./front-end/values.yaml" --namespace sock-shop
helm upgrade -i order "./order" --values="./order/values.yaml" --namespace sock-shop
helm upgrade -i payment "./payment" --values="./payment/values.yaml" --namespace sock-shop
helm upgrade -i queue-master "./queue-master" --values="./queue-master/values.yaml" --namespace sock-shop 
helm upgrade -i rabbitmq "./rabbitmq" --values="./rabbitmq/values.yaml" --namespace sock-shop
helm upgrade -i session "./session" --values="./session/values.yaml" --namespace sock-shop
helm upgrade -i shipping "./shipping" --values="./shipping/values.yaml" --namespace sock-shop
helm upgrade -i user "./user" --values="./user/values.yaml" --namespace sock-shop
# helm upgrade -i zipkin "./cart" --values="./cart/values.yaml" --namespace sock-shop