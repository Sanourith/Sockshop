# TODO
## k8s
- add service type ExternalName for all DB
- update values.yaml of all charts
## docker
- run all BD

## connect from minikube to docker
```sh
docker run -it --network helm-charts-v2_default --rm mongo mongosh --host carts-db
docker run -it --network helm-charts-v2_default --rm mongo mongosh --host orders-db

docker run -it --network helm-charts-v2_default --rm mongo3.4 mongo --host user-db