sudo docker container stop webserver php certbot
sudo docker container rm webserver php certbot

sudo docker system prune -a --volumes

sudo rm ./nginx/code/apps/wordpress/latest.tar.gz
sudo rm -rf ./nginx/code/apps/wordpress/wordpress
sudo rm ./nginx/config/default.conf
sudo rm docker-compose.yml

sudo docker container ls -a
