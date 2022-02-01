#!/bin/bash

sudo yum install epel-release -y
sudo yum update -y
sudo yum install -y docker git jq

# docker
sudo usermod -aG docker ec2-user
systemctl enable docker
systemctl start docker
# docker permissions
sudo chmod 666 /var/run/docker.sock
sudo chmod +x /usr/local/bin/docker-compose;


# docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
