#!/bin/bash

sudo yum install epel-release -y
sudo yum update -y
sudo yum install -y docker git jq

# Install go latest
wget https://storage.googleapis.com/golang/getgo/installer_linux
sudo chmod +x ./installer_linux
./installer_linux


## docker
sudo usermod -aG docker ec2-user
#systemctl enable docker
#systemctl start docker

# docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
