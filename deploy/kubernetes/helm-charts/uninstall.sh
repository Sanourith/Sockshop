#!/usr/bin/env bash

helm uninstall cart --namespace sock-shop
helm uninstall catalogue --namespace sock-shop
helm uninstall frontend --namespace sock-shop
helm uninstall order --namespace sock-shop
helm uninstall payment --namespace sock-shop
helm uninstall queue-master --namespace sock-shop 
helm uninstall rabbitmq --namespace sock-shop
helm uninstall session --namespace sock-shop
helm uninstall shipping --namespace sock-shop
helm uninstall user --namespace sock-shop
# helm uninstall --namespace sock-shop