pod/catalogue-d45f998bf-q5rl7      0/1     Running   0          62s
pod/payment-67f94cc7b8-kbr2p       0/1     Running   0          62s
pod/catalogue-db-d764d45d6-cdgvd   1/1     Running   0          62s  #MYSQL
pod/orders-779f959dc4-fcp76        1/1     Running   0          62s
pod/carts-666b98fdc4-snw5k         1/1     Running   0          62s
pod/queue-master-cc96b5649-96dqp   1/1     Running   0          62s
pod/shipping-7b856bf556-vxlk6      1/1     Running   0          61s
pod/user-745766f4f8-gvkgt          0/1     Running   0          61s
pod/rabbitmq-5c6f77d9dd-q6htr      2/2     Running   0          62s
pod/session-db-76d658cbf8-mj2hs    1/1     Running   0          61s     ?
pod/user-db-5bfb568f5b-hjhv6       1/1     Running   0          61s  #MONGODB
pod/carts-db-644ff6b576-j4xkw      1/1     Running   0          62s  #MONGODB
pod/orders-db-5bddcf9bdb-4948d     1/1     Running   0          62s  #MONGODB 
pod/front-end-7899799bbd-qq2g6     1/1     Running   0          62s


# cataloguedb :
# ROOT_PASSWORD : fake_password
# connexion au conteneur bdd :
kubectl exec -it ID_POD -- bash
mysqldump -u root -pfake_password --all-databases > backup.sql
# retour sur notre VM master :
kubectl cp ID_POD:backup.sql ./sauvegardes_bdd/catalogue-db.sql

# Pour les conteneurs : usersdb-cartsdb-ordersdb :
# connexion au conteneur bdd :
kubectl exec -it ID_POD -- bash
mkdir /tmp/backup
mongodump --out /tmp/backup
# retour sur notre VM master :
kubectl cp ID_POD:/tmp/backup ./sauvegardes_bdd

# J'ai qqs soucis de droits :
sudo chmod -R 777 /data/db
sudo chmod -R 777 /var/lib/kubelet/pods/UID/volumes/
# pour retrouver l'UID 
kubectl get pods POD -o json | grep uid


