

#! /bin/bash

list_images=("weaveworksdemos/front-end:0.3.12" XX
"weaveworksdemos/edge-router:0.1.1" 
"weaveworksdemos/catalogue:0.3.5"
"weaveworksdemos/catalogue-db:0.3.0"
"weaveworksdemos/carts:0.4.8"
"weaveworksdemos/orders:0.4.7"
"weaveworksdemos/shipping:0.4.8"
"weaveworksdemos/queue-master:0.3.1"
"weaveworksdemos/payment:0.4.3"
"weaveworksdemos/user:0.4.4"
"weaveworksdemos/user-db:0.4.0"
"weaveworksdemos/load-test:0.1.1")

for element in ${list_images[@]}
do
    docker pull $element
done

# for element in $'{list_images[@]}'
# do
#     docker build -t $element
# done

# docker build -t shopshosty
# docker push shopshosty/frontend:tagname















