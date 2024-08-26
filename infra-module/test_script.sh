#!/bin/bash


# Pour lancer ce script, positionnez vous dans shopshoty/

# Variables
EC2_USER="ec2-user"
PEM_PATH="./03.bastion/private-key/eks-terraform-key.pem"
BACKUP_PATH="../sauvegardes-bdd.tar"
DB_NAME="socksdb"
DB_USERNAME="maikiboss"
DB_PASSWORD="password"
GLOBAL_BUNDLE_URL="https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem"

# Obtenir les informations des outputs Terraform
cd ./03.bastion
EC2_IP=$(terraform output | grep ip | awk '{print $3}' | sed 's/"//g') 
echo $EC2_IP
cd ../

cd 07.docDB
DOCDB_ENDPOINT=$(terraform output | grep endpoint | awk '{print $3}')
echo $DOCDB_ENDPOINT
cd ../

cd 08.RDS
RDS_ENDPOINT=$(terraform output | grep db_instance_endpoint | awk '{print $3}' | sed 's/:3306//')
echo $RDS_ENDPOINT

cd ../

# Fonctions
transfer_files_to_ec2() {
    echo "Transfert des fichiers de sauvegarde vers EC2..."
    # echo "$PEM_PATH" "$EC2_USER@$EC2_IP" "tar -xvf ~/sauvegardes-bdd.tar -C ~/"
    # echo "$PEM_PATH" "$BACKUP_PATH" "$EC2_USER@$EC2_IP:~/sauvegardes-bdd.tar"
    # exit
    scp -i "$PEM_PATH" "$BACKUP_PATH" "$EC2_USER@$EC2_IP:~/sauvegardes-bdd.tar"
    ssh -i "$PEM_PATH" "$EC2_USER@$EC2_IP" "tar -xvf ~/sauvegardes-bdd.tar -C ~/"
}

install_mysql() {
    echo "Installation de MySQL sur EC2..."
    ssh -i "$PEM_PATH" "$EC2_USER@$EC2_IP" << 'EOF'
        sudo yum update -y
        sudo dnf install -y httpd mariadb105 wget php-fpm php-mysqli php-json php php-devel
        
EOF
}
# sudo systemctl start mysqld
# sudo systemctl enable mysqld
# sudo mysql_secure_installation

import_mysql_backup() {
    echo "Import des sauvegardes MySQL..."
    ssh -i "$PEM_PATH" "$EC2_USER@$EC2_IP" << EOF
        mysql -h $RDS_ENDPOINT -u $DB_USERNAME -p$DB_PASSWORD $DB_NAME < ~/sauvegardes-bdd/catalogue-db.sql
EOF
}
        # mysql -h $RDS_ENDPOINT -u $DB_USERNAME -p$DB_PASSWORD -e "source ~/sauvegardes-bdd/catalogue-db.sql"

install_mongodb() {
    echo "Installation de MongoDB sur EC2..."
    ssh -i "$PEM_PATH" "$EC2_USER@$EC2_IP" << 'EOF'
        sudo bash -c 'cat <<EOT > /etc/yum.repos.d/mongodb-org-7.0.repo
[mongodb-org-7.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/amazon/2023/mongodb-org/7.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://pgp.mongodb.com/server-7.0.asc
EOT'
        sudo dnf install -qy mongodb-mongosh-shared-openssl3 mongodb-database-tools
        sudo systemctl start mongod
        sudo systemctl enable mongod
EOF
}

import_docdb_backup() {
    echo "Import des sauvegardes MongoDB..."
    ssh -i "$PEM_PATH" "$EC2_USER@$EC2_IP" << EOF
        wget -O ~/global-bundle.pem $GLOBAL_BUNDLE_URL
        mongoimport --ssl --host $DOCDB_ENDPOINT --collection=carts-db --db=carts --numInsertionWorkers 2 --file="/home/ec2-user/sauvegardes-bdd/carts-db/system.version.metadata.json" --sslCAFile "/home/ec2-user/global-bundle.pem" --username $DB_USERNAME --password $DB_PASSWORD
        mongoimport --ssl --host $DOCDB_ENDPOINT --collection=orders-db --db=orders --numInsertionWorkers 2 --file="/home/ec2-user/sauvegardes-bdd/orders-db/system.version.metadata.json" --sslCAFile "/home/ec2-user/global-bundle.pem" --username $DB_USERNAME --password $DB_PASSWORD
        mongoimport --ssl --host $DOCDB_ENDPOINT --collection=user-db --db=user --numInsertionWorkers 2 --file="/home/ec2-user/sauvegardes-bdd/users-db/addresses.metadata.json" --sslCAFile "/home/ec2-user/global-bundle.pem" --username $DB_USERNAME --password $DB_PASSWORD
        mongoimport --ssl --host $DOCDB_ENDPOINT --collection=user-db --db=user --numInsertionWorkers 2 --file="/home/ec2-user/sauvegardes-bdd/users-db/cards.metadata.json" --sslCAFile "/home/ec2-user/global-bundle.pem" --username $DB_USERNAME --password $DB_PASSWORD
        mongoimport --ssl --host $DOCDB_ENDPOINT --collection=user-db --db=user --numInsertionWorkers 2 --file="/home/ec2-user/sauvegardes-bdd/users-db/customers.metadata.json" --sslCAFile "/home/ec2-user/global-bundle.pem" --username $DB_USERNAME --password $DB_PASSWORD     
EOF
}

#  mongorestore --ssl --host $DOCDB_ENDPOINT --sslCAFile ~/global-bundle.pem --collection=carts-db --db=carts --username $DB_USERNAME --password $DB_PASSWORD --dir ~/sauvegardes-bdd/carts-db
#         mongorestore --ssl --host $DOCDB_ENDPOINT --sslCAFile ~/global-bundle.pem --collection=orders-db --db=orders --username $DB_USERNAME --password $DB_PASSWORD --dir ~/sauvegardes-bdd/orders-db
#         mongorestore --ssl --host $DOCDB_ENDPOINT --sslCAFile ~/global-bundle.pem --collection=user-db --db=user --username $DB_USERNAME --password $DB_PASSWORD --dir ~/sauvegardes-bdd/users-db


# Exécution des fonctions
echo "transfer_files_to_ec2"
transfer_files_to_ec2
echo "install_mysql"
install_mysql
echo "import_mysql_backup"
import_mysql_backup
echo "install_mongodb"
install_mongodb
echo "import_docdb_backup"
import_docdb_backup

echo "Restauration des bases de données terminée."


# mongosh mongo --ssl --host sock-shop-docdb-staging-sockshop-db.cluster-cbgy0ouc03so.eu-west-3.docdb.amazonaws.com:27017 --sslCAFile global-bundle.pem --username maikiboss --password password --authenticationDatabase admin