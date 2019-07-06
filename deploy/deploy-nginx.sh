#!/bin/sh

sudo apt-get update 
sudo apt-get install -y git nginx

git clone https://github.com/mark-church/site.git

sudo mkdir /var/www/markchur.ch
sudo cp -r ./site/public/* /var/www/markchur.ch/
sudo cp ./site/deploy/etc/nginx/sites-available/markchur.ch-8080-prod /etc/nginx/sites-available
sudo cp ./site/deploy/etc/nginx/nginx.conf /etc/nginx/nginx.conf 

sudo rm /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/markchur.ch-8080-prod /etc/nginx/sites-enabled/
sudo nginx -s reload