#!/bin/bash

# Env variables
export DOMAIN='geekylanetest.com'
export DOMAIN_WWW='www.geekylanetest.com'
export PROD_OR_STAGING='--staging'

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
envsubst < "./docker-compose-templates/docker-compose-http.yml.template" > "docker-compose.yml"

# Create services "nodeJS", "webserver (nginx)" and "certbot"
sudo docker-compose up -d

envsubst < "./nginx/default-http.conf.template" > "./nginx/default.conf"

sleep 10

sudo docker-compose stop webserver

mkdir dhparam && \
sudo openssl dhparam -out $PWD/dhparam/dhparam-2048.pem 2048

envsubst < "./nginx/default-https.conf.template" > "./nginx/default.conf"

envsubst < "./docker-compose-templates/docker-compose-https.yml.template" > "docker-compose.yml"

sudo docker-compose up -d --force-recreate --no-deps webserver

