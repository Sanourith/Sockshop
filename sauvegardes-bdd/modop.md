
<!-- Copie des fichiers de sauvegardes dans l'EC2 + connexion :

```bash
scp -i "shop.pem" catalogue-db.sql ec2-user@13.37.249.179:~/catalogue-db.sql
scp -i "shop.pem" sauvegardes-bdd.tar ec2-user@15.236.229.253:~/databases.tar
ssh -i "shop.pem" ec2-user@13.37.249.179
``` -->

<!-- DOCUMENTS POUR LE TRANSFERT VERS EC2 -->
# MODOP -- transfert vers EC2-bastion

Avant de commencer la restauration de votre DB, veillez à effectuer les sauvegardes dump.sql (MySQL ou MariaDB) ou Mongodump (MongoDB) \

Ici :
```txt
fichiers : /home/sanou/shopshosty/sauvegardes-bdd.tar
clé.pem : /home/sanou/shopshosty/infra-module/05.bastion/private-key/eks-terraform-key.pem
```

1. Transfert des fichiers sur l'EC2 :\
Nom d'utilisateur Amazon Linux 2023 : ec2-user\
Nom d'utilisateur Ubuntu : ubuntu
```bash
# Pour se connecter à l'EC2 :
ssh -i "/home/oliveira/shopshosty/infra-module/03.bastion/private-key/eks-terraform-key.pem" ec2-user@15.236.187.126

# Pour transférer les sauvegardes DB :

scp -i "/home/oliveira/shopshosty/infra-module/03.bastion/private-key/eks-terraform-key.pem" sauvegardes-bdd.tar ec2-user@15.236.187.126:~/sauvegardes-bdd.tar

# modifier l'IP de l'EC2 et le chemin vers la clé.pem
```

Une fois connecté dans l'EC2, télécharger le global-bundle.pem pour permettre un accès standard :
```bash
wget https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem
```
C'est PARTIT !

# MySQL -- sur une image Amazon Linux 2023
1. INSTALLATION

```bash
sudo yum update
sudo dnf install -y httpd mariadb105 wget php-fpm php-mysqli php-json php php-devel
sudo systemctl start mysqld
sudo systemctl enable mysqld
sudo mysql_secure_installation
sudo systemctl status mysqld
```

2. (FACULTATIF) -- CREATION USER-DB

```bash
# Connexion à la DB MySQL :
mysql -h endpoint -P 3306 -u admin –p # vérif user dans vos fichiers helm / tf etc...

docker run -it --rm mysql mysql -hsocksdbinstance.cbgy0ouc03so.eu-west-3.rds.amazonaws.com -uadmin -p

docker run -i --rm mysql sh -c 'exec mysql -hsocksdbinstance.cbgy0ouc03so.eu-west-3.rds.amazonaws.com -uadmin -ppassword' < catalogue-db.sql

```

```txt
CREATE USER 'maikiboss'@'%' IDENTIFIED by "password";
CREATE DATABASE socksdb;
GRANT ALL PRIVILEGES ON socksdb.* TO 'maikiboss'@'%';
FLUSH PRIVILEGES;
EXIT;
```
3. IMPORT BDD dans MySQL \
Une fois connecté dans MySQL :
```bash
mysql -h endpoint -P 3306 -u USERNAME –p
mysql> source sauvegardes-bdd/catalogue-db.sql;

# OU depuis l'EC2 :
mysql -h ENDPOINT -P 3306 -u USERNAME –p DB < /chemin/vers/catalogue-db.sql
# remplacer l'ENDPOINT vers votre DB AWS RDS.

# On premise :
# On copie le fichier dans le conteneur mysql :
docker cp /home/sanou/shopshosty/sauvegardes-bdd/catalogue-db.sql 85125f462d50:/tmp/catalogue-db.sql
docker exec -it 85125f462d50 mysql -u root -p sockdb < /tmp/catalogue-db.sql


docker cp catalogue-db.sql ac0a0f85c768:/tmp/catalogue-db.sql
docker exec -it ac0a0f85c768 mysql -u root -ppassword 
>mysql> source catalogue-db.sql
```





#----#

# DOCUMENTDB -- sur une image Amazon Linux 2023
1. INSTALLATION :
```bash
sudo vim /etc/yum.repos.d/mongodb-org-7.0.repo
# ou nano
```
Inclure le texte suivant :
```txt
[mongodb-org-7.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/amazon/2023/mongodb-org/7.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://pgp.mongodb.com/server-7.0.asc
```
Lancer les fichiers d'installation suivants :
```bash
sudo dnf install -qy mongodb-mongosh-shared-openssl3
# ATTENTION, des erreurs sur les tuto d'installation relatifs à openSSL3, nécessaire à la bonne utilisation des mongos-tools
# sudo yum install -y nodejs 

sudo yum list installed mongodb-database-tools
sudo yum install mongodb-org-database mongodb-org-database-tools-extra
sudo dnf install -y mongodb-database-tools

### En cas d'anomalie d'install : 
sudo dnf erase -qy mongodb-mongosh
sudo dnf install -qy mongodb-mongosh-shared-openssl3
###

sudo systemctl start mongod
sudo systemctl daemon-reload
sudo systemctl enable mongod
sudo systemctl status mongod
```
1. (bis) INSTALLATION sur EC2 Ubuntu :
```bash
wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add - sudo apt-get install gnupg 
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list 
sudo apt-get update sudo apt-get install -y mongodb-org 
sudo systemctl start mongod 
sudo systemctl daemon-reload 
sudo systemctl status mongod
```


2. DOC pour importer la DB et la restaurer sur MONGO :
```bash
mongoimport --ssl \
       --host="tutorialCluster.amazonaws.com:27017" \
       --collection=Nomcollection \
       --db=Nomdb \
       --file=sauvegarde.json \ # json file
       --numInsertionWorkers 2 \
       --username=USERNAME \
       --password=PASSWORD \
       --sslCAFile /chemin/vers/global-bundle.pem

mongorestore --ssl \
       --host sock-shop-docdb-staging-sockshop-db.cluster-cmtyicphn7hn.eu-west-3.docdb.amazonaws.com:27017 \
       --collection=carts-db \
       --db=carts \
       --sslCAFile "/home/ec2-user/global-bundle.pem" \
       --username=USERNAME \
       --password=PASSWORD \
       /chemin/vers/savegarde.bson # bson file
```

#  SOCK-SHOP restauration des DB :

1. DB CARTS
```bash
mongoimport --ssl \
     --host sock-shop-docdb-staging-sockshop-db.cluster-cmtyicphn7hn.eu-west-3.docdb.amazonaws.com:27017 \
     --collection=carts-db \
     --db=carts \
     --numInsertionWorkers 2 \
     --file="/home/ec2-user/sauvegardes-bdd/carts-db/system.version.metadata.json" \
     --sslCAFile "/home/ec2-user/global-bundle.pem" \
     --username="maikiboss" \
     --password="password"

mongorestore --ssl \
      --host sock-shop-docdb-staging-sockshop-db.cluster-cmtyicphn7hn.eu-west-3.docdb.amazonaws.com:27017 \
      --collection=carts-db \
      --db=carts \
      --sslCAFile "/home/ec2-user/global-bundle.pem" \
      --username="maikiboss" \
      --password="password" \
      /home/ec2-user/sauvegardes-bdd/carts-db/system.version.bson
```

2. DB ORDERS
```bash
mongoimport --ssl \
     --host sock-shop-docdb-staging-sockshop-db.cluster-cmtyicphn7hn.eu-west-3.docdb.amazonaws.com:27017 \
     --collection=orders-db \
     --db=orders \
     --numInsertionWorkers 2 \
     --file="/home/ec2-user/sauvegardes-bdd/orders-db/system.version.metadata.json" \
     --sslCAFile "/home/ec2-user/global-bundle.pem" \
     --username="maikiboss" \
     --password="password"

mongorestore --ssl \
      --host sock-shop-docdb-staging-sockshop-db.cluster-cmtyicphn7hn.eu-west-3.docdb.amazonaws.com:27017 \
      --collection=orders-db \
      --db=orders \
      --sslCAFile "/home/ec2-user/global-bundle.pem" \
      --username="maikiboss" \
      --password="password" \
      /home/ec2-user/sauvegardes-bdd/orders-db/system.version.bson
```

3. DB USERS
```bash
mongoimport --ssl \
     --host sock-shop-docdb-staging-sockshop-db.cluster-cmtyicphn7hn.eu-west-3.docdb.amazonaws.com:27017 \
     --collection=users-db \
     --db=addresses \
     --numInsertionWorkers 2 \
     --file="/home/ec2-user/sauvegardes-bdd/users-db/addresses.metadata.json" \
     --sslCAFile "/home/ec2-user/global-bundle.pem" \
     --username="maikiboss" \
     --password="password"

mongorestore --ssl \
      --host sock-shop-docdb-staging-sockshop-db.cluster-cmtyicphn7hn.eu-west-3.docdb.amazonaws.com:27017 \
      --collection=users-db \
      --db=addresses \
      --sslCAFile "/home/ec2-user/global-bundle.pem" \
      --username="maikiboss" \
      --password="password" \
      /home/ec2-user/sauvegardes-bdd/users-db/addresses.bson

#### 

mongoimport --ssl \
     --host sock-shop-docdb-staging-sockshop-db.cluster-cmtyicphn7hn.eu-west-3.docdb.amazonaws.com:27017 \
     --collection=users-db \
     --db=cards \
     --numInsertionWorkers 2 \
     --file="/home/ec2-user/sauvegardes-bdd/users-db/cards.metadata.json" \
     --sslCAFile "/home/ec2-user/global-bundle.pem" \
     --username="maikiboss" \
     --password="password"

mongorestore --ssl \
      --host sock-shop-docdb-staging-sockshop-db.cluster-cmtyicphn7hn.eu-west-3.docdb.amazonaws.com:27017 \
      --collection=users-db \
      --db=cards \
      --sslCAFile "/home/ec2-user/global-bundle.pem" \
      --username="maikiboss" \
      --password="password" \
      /home/ec2-user/sauvegardes-bdd/users-db/cards.bson

####

mongoimport --ssl \
     --host sock-shop-docdb-staging-sockshop-db.cluster-cmtyicphn7hn.eu-west-3.docdb.amazonaws.com:27017 \
     --collection=users-db \
     --db=customers \
     --numInsertionWorkers 2 \
     --file="/home/ec2-user/sauvegardes-bdd/users-db/customers.metadata.json" \
     --sslCAFile "/home/ec2-user/global-bundle.pem" \
     --username="maikiboss" \
     --password="password"

mongorestore --ssl \
      --host sock-shop-docdb-staging-sockshop-db.cluster-cmtyicphn7hn.eu-west-3.docdb.amazonaws.com:27017 \
      --collection=users-db \
      --db=customers \
      --sslCAFile "/home/ec2-user/global-bundle.pem" \
      --username="maikiboss" \
      --password="password" \
      /home/ec2-user/sauvegardes-bdd/users-db/customers.bson
```


# DEPLOIEMENT Terraform : scripts DB

Install Chart

```bash
helm install [RELEASE_NAME] appvia-community/aws-rds-postgresql-database \
  --namespace [NAMESPACE] \
  --create-namespace \
  --set aws.region=[AWS_REGION] \
  --set aws.credentials=[AWS_CREDENTIALS] \
  --set rds.identifier=[RDS_IDENTIFIER] \
  --set rds.db_name=[RDS_DB_NAME] \²²
  --set rds.username=[RDS_DB_ADMIN] \
  --set rds.subnet_ids=[RDS_SUBNET_IDS] \
  --set rds.vpc_security_group_ids=[RDS_VPC_SECURITY_GROUPS]
```


  Upgrade Chart
```bash
helm upgrade --install [RELEASE_NAME] appvia-community/aws-rds-postgresql-database \
  --namespace [NAMESPACE] \
  --create-namespace \
  --set aws.region=[AWS_REGION] \
  --set aws.credentials=[AWS_CREDENTIALS] \
  --set rds.identifier=[RDS_IDENTIFIER] \
  --set rds.db_name=[RDS_DB_NAME] \
  --set rds.username=[RDS_DB_ADMIN] \
  --set rds.subnet_ids=[RDS_SUBNET_IDS] \
  --set rds.vpc_security_group_ids=[RDS_VPC_SECURITY_GROUPS]
```

  Uninstall Chart
```bash
helm uninstall [RELEASE_NAME]
```