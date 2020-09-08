sudo docker container stop webserver php certbot
sudo docker container rm webserver php certbot

sudo docker system prune -a --volumes

sudo docker container ls -a