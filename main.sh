#!/bin/bash

# Env variables
export DOMAIN='geekylanetest.com'
export DOMAIN_WWW='www.geekylanetest.com'
export PROD_OR_STAGING='--force-renewal'

# Update system
sudo apt update -y

# Install curl
sudo apt install -y curl

# Install docker and docker-compose
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

sudo curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# compose file without ssl-port and dhparam
envsubst '${PROD_OR_STAGING}' < "./docker-compose-templates/docker-compose-http.yml.template" > "docker-compose.yml"

# default file for nginx
envsubst '${DOMAIN},${DOMAIN_WWW}' < "./nginx/config/default-http.conf.template" > "./nginx/config/default.conf"

# Setting up the wordpress app
mkdir ./nginx/code/apps/wordpress
wget -P ./nginx/code/apps/wordpress https://wordpress.org/latest.tar.gz
tar -xzvf ./nginx/code/apps/wordpress/latest.tar.gz -C ./nginx/code/apps/wordpress


# Create services "webserver (nginx)" and "certbot = Exit (0)"
sudo docker-compose up -d

sleep 10

sudo docker-compose stop webserver

mkdir dhparam && \
sudo openssl dhparam -out $PWD/dhparam/dhparam-2048.pem 2048

envsubst '${DOMAIN},${DOMAIN_WWW}' < "./nginx/config/default-https.conf.template" > "./nginx/config/default.conf"

envsubst '${PROD_OR_STAGING}' < "./docker-compose-templates/docker-compose-https.yml.template" > "docker-compose.yml"

sudo docker-compose up -d --force-recreate --no-deps webserver

