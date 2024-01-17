#!/bin/bash
sudo apt update -y &&
sudo apt install -y nginx
echo "Look no further, I'm here" > /var/www/html/index.html